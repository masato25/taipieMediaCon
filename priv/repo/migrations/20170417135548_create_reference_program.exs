defmodule TaipieMediaCon.Repo.Migrations.CreateReferenceProgram do
  use Ecto.Migration

  def change do
    alter table(:time_job) do
      add :program_id, references(:program, type: :integer, null: false)
    end
  end
end
