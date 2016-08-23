defmodule Runnel.RedirectOrSigninCookie do
  import Plug.Conn

  def init(options), do: options

  def call(conn, options) do
    perform_redirect(conn, conn.cookies["access_token"])
  end

  defp perform_redirect(conn, nil) do
    conn
    |> Phoenix.Controller.redirect(to: "/auth")
    |> halt
  end

  defp perform_redirect(conn, access_token) do
    conn
    |> assign(:access_token, access_token)
  end
end
