defmodule Runnel.AuthController do
  use Runnel.Web, :controller
  alias Runnel.Authenticator

  def index(conn, _params) do
    conn
    |> render_form_or_skip(conn.assigns[:access_token])
    |> put_layout("public.html")
    |> render("index.html")
  end

  def create_session(conn, %{"nike_session" => %{"username" => username, "password" => password}}) do
    case Authenticator.login(username, password) do
      {:ok, token} ->
        conn
        |> put_resp_cookie("access_token", token, max_age: 3500)
        |> redirect(to: page_path(conn, :index))
      {:error, _} ->
        conn
        |> put_flash(:error, "couldnt login")
        |> redirect(to: auth_path(conn, :index))
    end
  end

  defp render_form_or_skip(conn, nil), do: conn

  defp render_form_or_skip(conn, _) do
    conn
    |> redirect(to: page_path(conn, :index))
    |> halt
  end
end
