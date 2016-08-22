defmodule Runnel.PageController do
  use Runnel.Web, :controller

  plug :valid_token when action in [:see_stuff]

  def see_stuff(conn, _params) do
    data = Runnel.Integrations.NikeRuns.fetch(conn.cookies["access_token"])

    conn
    |> assign(:data, data)
    |> render("see_stuff.html")
  end

  defp valid_token(conn, _) do
    if is_binary(conn.cookies["access_token"]) do
      conn
    else
      conn |> put_flash(:info, "needs to login") |> redirect(to: "/") |> halt
    end
  end
end
