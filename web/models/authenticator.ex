defmodule Runnel.Authenticator do
  def login(username, password)  do
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
