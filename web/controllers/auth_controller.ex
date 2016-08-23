defmodule Runnel.AuthController do
  use Runnel.Web, :controller

  def index(conn, _params) do
    conn
    |> render_form_or_skip(conn.assigns[:access_token])
    |> render("index.html")
  end

  def create_session(conn, %{"nike_session" => %{"username" => username, "password" => password}}) do
    case login(username, password) do
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

  defp login(username, password)  do
    login_endpoint = "https://developer.nike.com/services/login"

    case HTTPoison.post(login_endpoint, {:form, [ username: username, password: password ]}) do
      {:ok, response} -> extract_token(response.body)
      {:error, _} -> { :error, "couldnt login" }
    end
  end

  defp extract_token(response) do
    response
    |> Poison.decode!
    |> Enum.find_value(fn
      ({"access_token", v}) -> { :ok, to_string(v) }
      ({_,_}) -> {:error, "couldnt login"}
    end)
  end

  defp render_form_or_skip(conn, nil), do: conn

  defp render_form_or_skip(conn, _) do
    conn
    |> redirect(to: page_path(conn, :index))
    |> halt
  end
end
