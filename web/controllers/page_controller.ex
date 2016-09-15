defmodule Runnel.PageController do
  use Runnel.Web, :controller
  import Ecto.Query, only: [from: 2]

  def index(conn, _params) do
    query = from Runnel.NikeRun, order_by: [desc: :start_time]

    runs = Runnel.Repo.all(query)

    conn
    |> assign(:runs, runs)
    |> render("index.html")
  end

  def show(conn, %{"run_id" => run_id}) do
    activity = Repo.get_by(Runnel.NikeRun, activity_id: run_id)

    conn
    |> assign(:data, activity)
    |> render("show.html")
  end
end
