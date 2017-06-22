defmodule TaipieMediaCon.Repo.Migrations.CreateProgram do
  use Ecto.Migration

  def change do
    create table(:program) do
      add :name, :string
      add :command, :string
      add :descript, :string
      add :other, :string

      timestamps()
    end

  end
end
