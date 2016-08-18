defmodule Runnel.PageController do
  use Runnel.Web, :controller
  require IEx

  plug :valid_token when action in [:see_stuff]

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

  def see_stuff(conn, _params) do
    data = Runnel.Integrations.NikeRuns.fetch(conn.cookies["access_token"])

    conn
    |> assign(:data, data)
    |> render("see_stuff.html")
  end

  defp login(username, password)  do
    login_endpoint = "https://developer.nike.com/services/login"

    case HTTPoison.post(login_endpoint, {:form, [ username: username, password: password ]}) do
      {:ok, response} -> extract_token(response.body)
      {:error, _} -> { :error, "coudnt login"}
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

  defp valid_token(conn, _) do
    if is_binary(conn.cookies["access_token"]) do
      conn
    else
      conn |> put_flash(:info, "needs to login") |> redirect(to: "/") |> halt
    end
  end
end
