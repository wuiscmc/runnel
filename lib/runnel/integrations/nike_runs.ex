defmodule Runnel.Integrations.NikeRuns do
 use HTTPoison.Base

 # GET https://api.nike.com/v1/me/sport/activities?access_token={access_token}&count=10&startDate=2012-01-01&endDate=2014-02-15
 def process_url(url) do
    Application.get_env(:runnel, Runnel.Integrations.NikeRuns)[:api_url] <> url
 end

 def fetch(access_token) do
   get!("/me/sport/activities/RUNNING",
    [],
    [params: [
      access_token: access_token
    ]]).body
 end

 def fetch(access_token, run_id, true) do
   get!("/me/sport/activities/#{run_id}/gps",
    [],
    [params: [
      access_token: access_token
    ]]).body
 end


 def fetch(access_token, run_id, gps \\ false) do
   get!("/me/sport/activities/#{run_id}",
    [],
    [params: [
      access_token: access_token
    ]]).body
 end

 def process_response_body(body) do
   body
   |> Poison.decode!
   |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
 end
end
