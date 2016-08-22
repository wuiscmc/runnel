defmodule Runnel.AuthController do
  use Runnel.Web, :controller

  def index(conn, _params) do
    if conn.cookies["access_token"] do
      conn
      |> redirect to: "/see_stuff"
    else
      conn
      |> render("index.html")
    end
  end

  def create_session(conn, %{"nike_session" => %{"username" => username, "password" => password}}) do
    case login(username, password) do
      {:ok, token} ->
        conn
        |> put_resp_cookie("access_token", token, max_age: 3500)
        |> redirect to: "/see_stuff"
      {:error, _} ->
        conn
        |> put_flash(:error, "couldnt login")
        |> redirect to: "/"
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
end
