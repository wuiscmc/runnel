defmodule Waypoint do
  @behaviour Ecto.Type

  def type, do: :map

  def cast(map) when is_map(map) do
    reduced_map = map
                  |> Enum.reduce(%{}, fn({k,v}, atom_map) -> Map.put(atom_map, to_string(k), v) end)
                  |> Map.take(["latitude", "longitude"])

    if is_binary(reduced_map["latitude"]) && is_binary(reduced_map["longitude"]) do
      {:ok, %{"lat" => reduced_map["latitude"], "lng" => reduced_map["longitude"]}}
    else
      :error
    end
  end

  def cast(_), do: :error

  def load(map) when is_map(map) do
    map
    # case Ecto.Type.load(:map, map) do
    #   {:ok, formatted_map } -> %{latitude: formatted_map["lat"], longitude: formatted_map["lng"]}
    #   :error -> :error
    # end
  end

  def dump(map) when is_map(map) do
    exists = map
              |> Map.keys
              |> Enum.map(fn(key) -> Enum.member?(["lat", "lng"], to_string(key)) end)


    if exists == [true, true] do
      {:ok, %{"lat" => map[:latitude], "lng" => map[:longitude]}}
    else
      :error
    end
  end

  def dump(_), do: :error
end
