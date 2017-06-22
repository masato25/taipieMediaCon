defmodule TaipieMediaCon.Repo.Migrations.CreateJobTemplate do
  use Ecto.Migration

  def change do
    create table(:job_template) do
      add :name, :string

      timestamps()
    end

  end
end
