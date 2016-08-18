defmodule Runnel.PageController do
  use Runnel.Web, :controller

  def index(conn, _params) do
    token = login(conn.cookies["access_token"])
    data = Runnel.Integrations.NikeRuns.fetch(token)

    conn
    |> put_resp_cookie("access_token", token, max_age: 3500)
    |> assign(:data, data)
    |> render("index.html")
  end

  defp login(_)  do
    HTTPoison.post!("https://developer.nike.com/services/login", {:form, [username: "u", password: "b"]}).body 
    |> Poison.decode!
    |> Enum.find_value(fn
       ({"access_token", v}) -> to_string(v)
    end)
  end

  defp login(token) when is_binary(token) do
    token
  end
end
