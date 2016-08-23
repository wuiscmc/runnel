defmodule Runnel.PageController do
  use Runnel.Web, :controller

  def index(conn, _params) do
    data = Runnel.Integrations.NikeRuns.fetch(conn.assigns.access_token)

    conn
    |> assign(:data, data)
    |> render("see_stuff.html")
  end
end
