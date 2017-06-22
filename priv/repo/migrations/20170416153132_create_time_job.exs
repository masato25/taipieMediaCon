defmodule TaipieMediaCon.Repo.Migrations.CreateTimeJob do
  use Ecto.Migration

  def change do
    create table(:time_job) do
      add :start_time, :datetime
      add :end_time, :datetime

      timestamps()
    end

  end
end
