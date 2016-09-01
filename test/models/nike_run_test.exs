defmodule Runnel.NikeRunTest do
  use Runnel.ModelCase

  alias Runnel.NikeRun

  @valid_attrs %{calories: 42, distance: "120.5", duration: %{hour: 14, min: 0, sec: 0}, start_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, user_id: 42, waypoints: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = NikeRun.changeset(%NikeRun{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = NikeRun.changeset(%NikeRun{}, @invalid_attrs)
    refute changeset.valid?
  end
end
