defmodule Runnel.Repo.Migrations.AddActivityIdUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:nike_runs, [:activity_id])
  end
end
