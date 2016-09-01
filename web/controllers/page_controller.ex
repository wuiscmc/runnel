defmodule Runnel.PageController do
  use Runnel.Web, :controller
  alias Runnel.NikePlusService

  def index(conn, _params) do
    activities = NikePlusService.activities_list(conn.assigns.access_token)

    conn
    |> assign(:data, activities)
    |> render("see_stuff.html")
  end

  def show(conn, %{"run_id" => run_id}) do
    activity = NikePlusService.activity(conn.assigns.access_token, run_id)

    conn
    |> assign(:data, activity)
    |> render("run.html")
  end
end
