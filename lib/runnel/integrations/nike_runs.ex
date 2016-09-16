defmodule Runnel.Integrations.NikeRuns do
  use HTTPoison.Base
  require Logger

  # GET https://api.nike.com/v1/me/sport/activities?access_token={access_token}&count=10&startDate=2012-01-01&endDate=2014-02-15
  def process_url(url) do
    Application.get_env(:runnel, Runnel.Integrations.NikeRuns)[:api_url] <> url
  end

  def fetch_activity_list(access_token, params \\ []) do
    request("/me/sport/activities/RUNNING", access_token, params)
  end

  def fetch_activity(access_token, run_id, params \\ []) do
    endpoint = "/me/sport/activities/#{run_id}"

    endpoint = if params[:gps], do: endpoint <> "/gps", else: endpoint
    request(endpoint, access_token)
  end

  def process_response_body(body) do
    body |> Poison.decode!
  end

  defp request(endpoint, access_token, params \\ []) do
    query_params = [ {:access_token, access_token} | params ]

    log_request(endpoint, query_params)

    case get(endpoint, [], [params: query_params]) do
      {:error, _}     -> Logger.error("could not fetch data" <> endpoint)
      {:ok, response} -> response.body
    end
  end

  defp log_request(endpoint, params) do
    params
    |> Enum.reduce("", fn({key, value}, debug_string) ->"[#{ to_string(key) }=#{value}] " <> debug_string end)
    |> (&Logger.debug("[nike_api_request] [endpoint=#{endpoint}] " <> &1)).()
  end
end
