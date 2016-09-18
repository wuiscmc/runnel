defmodule Runnel.NikeService do
  require Logger
  import Ecto.Query, only: [from: 2]
  alias Runnel.Integrations.NikeApi
  alias Runnel.NikeRun

  def import_latest_runs(token) do
    Logger.debug "extract_new_runs"

    token
    |> fetch_latest_runs
    |> Enum.each(fn(run) ->
     {:ok, _pid} = Task.Supervisor.start_child(Runnel.NikeRunTaskSupervisor, __MODULE__, :import_run, [token, run])
    end)
  end

  def import_all_runs(token) do
    Logger.debug "extract_new_runs"

    max_db_connections = Application.get_env(:runnel, Runnel.Repo)[:pool_size] - 1

    runs = token
    |> fetch_all_runs

    chunk_size = div(length(runs), max_db_connections)

    runs
    |> Enum.chunk(20, 20, [])
    |> Enum.each(fn(chunk) ->
      case Task.Supervisor.start_child(Runnel.NikeRunTaskSupervisor, __MODULE__, :import_chunk, [token, chunk]) do
        {:ok, pid} -> {:ok, pid}
        _ -> Logger.debug("something went wrong")
      end
    end)
  end

  def import_chunk(token, chunk) do
    Logger.debug("importing chunk")
    Enum.each(chunk, fn(run) ->
      import_run(token, run)
    end)

    Logger.debug("chunk done")
  end

  def import_run(token, run_id) do
    unless Runnel.Repo.get_by(NikeRun, activity_id: run_id) do
      run = run_id
            |> fetch_run_data(token)
            |> (&NikeRun.changeset(%NikeRun{}, &1)).()

      case Runnel.Repo.insert(run) do
          {:error, _} -> Logger.error("could not insert run: #{run_id}")
          {:ok, run}  -> run
      end
    end
  end

  defp fetch_latest_runs(token) do
    Logger.debug "fetch_latest_runs"

    query = from run in NikeRun, select: run.start_time, limit: 1, order_by: [desc: :start_time]

    params = case Runnel.Repo.one(query) do
      nil -> [count: 20]

      %Ecto.DateTime{} = datetime ->
        { start_date, end_date } = build_date_range_from_datetime(datetime)
        [startDate: start_date, endDate: end_date, count: 20]
    end

    %{"data" => data} = NikeApi.fetch_activity_list!(token, params)

    Enum.map(data, fn(%{"activityId" => run_id}) -> run_id end)
  end

  def fetch_all_runs(token, params \\ []) do
    Logger.debug("fetch runs")

    token
    |> loop_over_all_runs(params, [])
    |> Enum.map(fn(%{"activityId" => run_id}) -> run_id end)
  end

  def loop_over_all_runs(token, params \\ [], runs \\ []) do
    case NikeApi.fetch_activity_list(token, params) do
      {:eol, %{}}                -> runs
      {:eol, %{"data" => data}}  -> data
      {:more, %{"data" => data}} ->
        # new_params = Enum.reject(params, fn(
        #   {param,_} -> param !== :offset
        # end)

        new_offset = ( params[:offset] || 1 ) + 20
        new_params = [offset: new_offset, count: 20]
        loop_over_all_runs(token, new_params, data ++ runs)
    end
  end

  defp fetch_run_data(run_id, token) do
    Logger.debug "fetch_run_data for #{run_id}"

    run_data = NikeApi.fetch_activity(token, run_id, gps: false)
    gps_coordinates = fetch_run_gps_data(token, run_id, run_data["isGpsActivity"])

    %{
      calories: run_data["metricSummary"]["calories"],
      duration: run_data["metricSummary"]["duration"],
      distance: run_data["metricSummary"]["distance"],
      start_time: run_data["startTime"],
      waypoints: gps_coordinates,
      activity_id: run_data["activityId"],
      user_id: 1,
    }
  end

  defp fetch_run_gps_data(token, run_id, true) do
    response = NikeApi.fetch_activity(token, run_id, gps: true)

    case response do
      %{"error_id" => _, "errors" => _} -> []
      %{"waypoints" => waypoints} ->
        waypoints
        |> Enum.map(fn(waypoint) -> %{ "lng" => waypoint["longitude"], "lat" => waypoint["latitude"] } end)
    end

  end

  defp fetch_run_gps_data(_token, _run_id, _data), do: []

  defp build_date_range_from_datetime(datetime) do
      start_date = datetime
                    |> Ecto.DateTime.to_date
                    |> Ecto.Date.to_string

      end_date = :calendar.local_time
                  |> Ecto.DateTime.from_erl
                  |> Ecto.DateTime.to_date
                  |> Ecto.Date.to_string

      {start_date, end_date}
  end
end
