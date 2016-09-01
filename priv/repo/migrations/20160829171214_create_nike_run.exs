defmodule Runnel.Repo.Migrations.CreateNikeRun do
  use Ecto.Migration

  def change do
    create table(:nike_runs) do
      add :user_id, :integer
      add :waypoints, {:array, :map}, default: [] #{:array, :map}, default: []
      add :start_time, :datetime
      add :calories, :integer
      add :duration, :time
      add :distance, :float
      add :activity_id, :string

      timestamps()
    end

  end
end
