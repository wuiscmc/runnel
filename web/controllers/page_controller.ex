defmodule Runnel.PageController do
  use Runnel.Web, :controller

  def index(conn, _params) do
    data = Runnel.Integrations.NikeRuns.fetch(conn.assigns.access_token)

    conn
    |> assign(:data, data)
    |> render("see_stuff.html")
  end

  def show(conn, %{"run_id" => run_id}) do
    data = Runnel.Integrations.NikeRuns.fetch(conn.assigns.access_token, run_id)

    conn
    |> assign(:data, data)
    |> render("run.html")
  end


end
