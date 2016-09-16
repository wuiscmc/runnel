defmodule Runnel.NikeService do
  require Logger
  import Ecto.Query, only: [from: 2]
  alias Runnel.NikeRun

  def fetch_new_runs(token) do
    Logger.debug "extract_new_runs"

    token
    |> fetch_latest_runs
    |> Enum.each(fn(run) ->
     {:ok, _pid} = Task.Supervisor.start_child(Runnel.NikeRunTaskSupervisor, __MODULE__, :import_run, [token, run])
    end)
  end

  def import_run(token, run_id) do
    run = run_id
          |> fetch_run_data(token)
          |> (&NikeRun.changeset(%NikeRun{}, &1)).()

    case Runnel.Repo.insert(run) do
        {:error, _} -> Logger.error("could not insert run: #{run_id}")
        {:ok, run}  -> run
    end
  end

  defp fetch_latest_runs(token) do
    Logger.debug "fetch_latest_runs"

    query = from run in NikeRun, select: run.start_time, limit: 1, order_by: [desc: :start_time]

    activities = case Runnel.Repo.one(query) do
      nil ->
        Runnel.Integrations.NikeRuns.fetch_activity_list(token, count: 20)

      %Ecto.DateTime{} = datetime ->
        Logger.debug "fetching from #{datetime}"

        start_date = datetime
                      |> Ecto.DateTime.to_date
                      |> Ecto.Date.to_string

        end_date = :calendar.local_time
                    |> Ecto.DateTime.from_erl
                    |> Ecto.DateTime.to_date
                    |> Ecto.Date.to_string

        Runnel.Integrations.NikeRuns.fetch_activity_list(token, count: 20, startDate: start_date, endDate: end_date)
    end

    Enum.map(activities["data"], fn(activity) -> activity["activityId"] end)
  end

  defp fetch_run_data(run_id, token) do
    Logger.debug "fetch_run_data for #{run_id}"

    run_data = Runnel.Integrations.NikeRuns.fetch_activity(token, run_id, gps: false)
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

  def fetch_run_gps_data(token, run_id, true) do
    response = Runnel.Integrations.NikeRuns.fetch_activity(token, run_id, gps: true)

    case response do
      %{"error_id" => _, "errors" => _} -> []
      %{"waypoints" => waypoints} ->
        waypoints
        |> Enum.map(fn(waypoint) -> %{ "lng" => waypoint["longitude"], "lat" => waypoint["latitude"] } end)
    end

  end

  def fetch_run_gps_data(_token, _run_id, _data), do: []
end
