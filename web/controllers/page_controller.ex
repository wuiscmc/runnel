defmodule Runnel.PageController do
  use Runnel.Web, :controller

  def index(conn, _params) do
    activities = Runnel.Repo.all(Runnel.NikeRun)

    conn
    |> assign(:data, activities)
    |> render("index.html")
  end

  def show(conn, %{"run_id" => run_id}) do
    activity = Repo.get_by(Runnel.NikeRun, activity_id: run_id)

    conn
    |> assign(:data, activity)
    |> render("show.html")
  end
end
