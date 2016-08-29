defmodule Runnel.PageController do
  use Runnel.Web, :controller

  def index(conn, _params) do
    data = Runnel.Integrations.NikeRuns.fetch(conn.assigns.access_token)

    conn
    |> assign(:data, data)
    |> render("see_stuff.html")
  end

  def show(conn, %{"run_id" => run_id}) do
    run_data = Runnel.Integrations.NikeRuns.fetch(conn.assigns.access_token, run_id)

    data_with_gps = data_with_gps(conn.assigns.access_token, run_id, run_data[:isGpsActivity])

    run_data_with_gps = Map.take(run_data[:metricSummary], ["calories", "duration", "distance"])
      |> Map.put("waypoints", data_with_gps)
      |> Map.put("startTime", run_data[:startTime])

    conn
    |> assign(:data, run_data_with_gps)
    |> render("run.html")
  end

  defp data_with_gps(token, run_id, true) do
    data = Runnel.Integrations.NikeRuns.fetch(token, run_id, true)

    case List.first(data) do
      {:error_id, data} -> []
      other ->
        Enum.map(data[:waypoints], fn
          (waypoint) -> %{ "lng" => waypoint["longitude"], "lat" => waypoint["latitude"] }
        end)
    end
  end

  defp data_with_gps(_token, _run_id, _data), do: []
end
