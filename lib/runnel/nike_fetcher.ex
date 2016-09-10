defmodule Runnel.NikeFetcher do
  use GenServer
  require Logger
  import Ecto.Query, only: [from: 2]

  def start_link(opts \\ []) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, [], opts)
  end

  def init(state) do
    schedule_poll(1_000)
    {:ok, state}
  end

  def handle_info(:work, state) do
    token = get_token
    extract_new_runs(token, fetch_latest_remote_activity_ids(token), fetch_latest_db_activity_ids)

    Logger.debug "scheduling again"
    schedule_poll(600_000)
    {:noreply, state}
  end

  defp schedule_poll(time) do
    Process.send_after(self(), :work, time)
  end

  defp extract_new_runs(token, activity_ids, nike_runs) when length(activity_ids) > 0 do
    Logger.debug "extract_new_runs"

    MapSet.difference(MapSet.new(activity_ids), MapSet.new(nike_runs))
    |> Enum.each(&fetch_activity(token, &1))
  end

  defp fetch_activity(token, run_id) do
    run_data = Runnel.Integrations.NikeRuns.fetch(token, run_id)

    data = %{
      calories: run_data[:metricSummary]["calories"],
      duration: run_data[:metricSummary]["duration"],
      distance: run_data[:metricSummary]["distance"],
      start_time: run_data[:startTime],
      waypoints: data_with_gps(token, run_id, run_data[:isGpsActivity]),
      activity_id: run_data[:activityId],
      user_id: 1,
    }

    data
    |> (&Runnel.NikeRun.changeset(%Runnel.NikeRun{}, &1)).()
    |> Runnel.Repo.insert!
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

  defp data_with_gps(_token, _run_id, _data), do: []

  defp fetch_latest_remote_activity_ids(token) do
    Logger.debug "fetch_latest_remote_activity_ids"

    activities = Runnel.Integrations.NikeRuns.fetch(token)
    Enum.map(activities[:data], fn(activity) -> activity["activityId"] end)
  end

  defp get_token do
    credentials = Application.get_env(:runnel, Runnel.NikeFetcher)[:credentials]
    Logger.debug "get_token for #{credentials[:username]}"

    {:ok, token} = Runnel.Authenticator.login(credentials[:username], credentials[:password])
    token
  end

  defp fetch_latest_db_activity_ids do
    Logger.debug "fetch_latest_db_activity_ids"

    query = from run in Runnel.NikeRun, select: run.activity_id, limit: 5
    Runnel.Repo.all(query)
  end
end
