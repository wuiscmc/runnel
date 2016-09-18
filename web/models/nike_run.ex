defmodule Runnel.NikeRun do
  use Runnel.Web, :model

  # A waypoint is defined by "lat|long" formatted string where
  #   - lat is the latitutde of the waypoint
  #  - long is the longitude of the waypont
  #  ie. given "41.85|-87.65":
  #   - lat = 41.85
  #   - long = -87.65

  schema "nike_runs" do
    field :user_id, :integer
    field :waypoints, {:array, :map}
    field :start_time, Ecto.DateTime
    field :calories, :integer
    field :duration, :string
    field :distance, :float
    field :activity_id, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :waypoints, :start_time, :duration, :calories, :distance, :activity_id])
    |> validate_required([:user_id, :activity_id, :start_time, :duration, :distance])
    |> unique_constraint(:activity_id)
  end

  def to_string(%Runnel.NikeRun{} = run) do
    [:user_id, :start_time, :calories, :duration, :distance, :activity_id]
    |> Enum.reduce("", fn(field, string) ->
        value = (Map.fetch!(run, field)  || "nil") |> Kernel.to_string
        "#{Kernel.to_string(field)}=#{value} " <> string
      end)
  end
end
