defmodule Runnel.NikePlusService do
  use Runnel.Web, :service

  alias Runnel.NikeRun

  def activities_list(token) do
    Runnel.Integrations.NikeRuns.fetch(token)
  end

  def activity(token, run_id) do
    case Repo.get_by(NikeRun, activity_id: run_id) do
      %NikeRun{} = record -> record

      nil ->
        run_data = Runnel.Integrations.NikeRuns.fetch(token, run_id)

        data_with_gps = data_with_gps(token, run_id, run_data[:isGpsActivity])

        Map.take(run_data[:metricSummary], ["calories", "duration", "distance"])
          |> Map.put("waypoints", data_with_gps)
          |> Map.put("start_time", run_data[:startTime])
          |> Map.put("activity_id", run_data[:activityId])
          |> save_activity
        end
  end

  defp data_with_gps(token, run_id, true) do
    data = Runnel.Integrations.NikeRuns.fetch(token, run_id, true)

    case List.first(data) do
      {:error_id, _data} -> []
      _other ->
        Enum.map(data[:waypoints], fn
          (waypoint) -> %{ "lng" => waypoint["longitude"], "lat" => waypoint["latitude"] }
        end)
    end
  end

  def save_activity(data) do
    data = Enum.reduce(data, %{}, fn({k,v}, map) -> Map.put(map, String.to_atom(k), v) end)

    NikeRun.changeset(%NikeRun{}, Map.put(data, :user_id, 1))
    |> Repo.insert!
  end

  defp data_with_gps(_token, _run_id, _data), do: []
end
