defmodule Runnel.NikeService do
  require Logger
  import Ecto.Query, only: [from: 2]

  def fetch_new_runs(token) do
    Logger.debug "extract_new_runs"

    new_runs = MapSet.difference(fetch_latest_runs(token), fetch_local_runs)

    Enum.each(new_runs, fn(run) ->
     {:ok, _pid} = Task.Supervisor.start_child(Runnel.NikeRunTaskSupervisor, __MODULE__, :import_run, [token, run])
    end)
  end

  def import_run(token, data) do
    fetch_run_data(token, data)
    |> save_run_data
  end

  defp fetch_latest_runs(token) do
    Logger.debug "fetch_latest_runs"
    query = from run in Runnel.NikeRun, select: run.start_time, limit: 1, order_by: [desc: :start_time]
    case Runnel.Repo.one(query) do
      nil ->
        activities = Runnel.Integrations.NikeRuns.fetch_activity_list(token, count: 20)
        Enum.map(activities["data"], fn(activity) -> activity["activityId"] end)
        |> MapSet.new

      %Ecto.DateTime{} = datetime ->
        Logger.debug "fetching from #{datetime}"

        start_date = datetime
                    |> Ecto.DateTime.to_date
                    |> Ecto.Date.to_string

        end_date = :calendar.local_time
                    |> Ecto.DateTime.from_erl
                    |> Ecto.DateTime.to_date
                    |> Ecto.Date.to_string

        activities = Runnel.Integrations.NikeRuns.fetch_activity_list(token, count: 20, startTime: start_date, endTime: end_date)
        Enum.map(activities["data"], fn(activity) -> activity["activityId"] end)
        |> MapSet.new
    end

  end

  defp fetch_local_runs do
    Logger.debug "fetch_local_runs"

    Runnel.Repo.all(from run in Runnel.NikeRun, select: run.activity_id)
    |> MapSet.new
  end

  defp fetch_run_data(token, run_id) do
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

  defp save_run_data(run_data) do
    run_data
    |> (&Runnel.NikeRun.changeset(%Runnel.NikeRun{}, &1)).()
    |> Runnel.Repo.insert!
  end

  def fetch_run_gps_data(token, run_id, true) do
    response = Runnel.Integrations.NikeRuns.fetch_activity(token, run_id, gps: true)

    case response do
      %{"error_id" => _, "errors" => _} -> []
      _ ->
        Enum.map(response["waypoints"], fn(waypoint) ->
          %{
            "lng" => waypoint["longitude"],
            "lat" => waypoint["latitude"]
          }
        end)
    end

  end

  def fetch_run_gps_data(_token, _run_id, _data), do: []
end
