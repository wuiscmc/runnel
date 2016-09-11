defmodule Runnel.NikeService do
  require Logger
  import Ecto.Query, only: [from: 2]

  def fetch_new_runs(token) do
    Logger.debug "extract_new_runs"

    new_runs = MapSet.difference(fetch_latest_runs(token), fetch_local_runs)

    new_runs
    |> Enum.map(&fetch_run_data(token, &1))
    |> Enum.map(&save_run_data(&1))
  end

  defp fetch_latest_runs(token) do
    Logger.debug "fetch_latest_runs"

    activities = Runnel.Integrations.NikeRuns.fetch(token)
    Enum.map(activities["data"], fn(activity) -> activity["activityId"] end)
    |> MapSet.new
  end

  defp fetch_local_runs do
    Logger.debug "fetch_local_runs"

    Runnel.Repo.all(from run in Runnel.NikeRun, select: run.activity_id)
    |> MapSet.new
  end

  defp fetch_run_data(token, run_id) do
    Logger.debug "fetch_run_data for #{run_id}"
    run_data = Runnel.Integrations.NikeRuns.fetch(token, run_id, gps: false)
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
    response = Runnel.Integrations.NikeRuns.fetch(token, run_id, gps: true)

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
