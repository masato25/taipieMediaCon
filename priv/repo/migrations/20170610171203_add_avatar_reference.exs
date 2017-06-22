defmodule TaipieMediaCon.Repo.Migrations.AddAvatarReference do
  use Ecto.Migration

  def change do
    alter table(:avatar) do
      add :job_template_id, references(:job_template, type: :integer, null: true)
      add :time_job_id, references(:time_job, type: :integer, null: true)
    end
    create index(:avatar, [:name], unique: true)
  end

end
