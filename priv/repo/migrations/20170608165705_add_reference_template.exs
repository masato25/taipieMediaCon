defmodule TaipieMediaCon.Repo.Migrations.AddReferenceTemplate do
  use Ecto.Migration

  def change do
    alter table(:time_job) do
      add :job_template_id, references(:job_template, type: :integer, null: false)
    end
    create index(:job_template, [:name], unique: true)
  end
end
