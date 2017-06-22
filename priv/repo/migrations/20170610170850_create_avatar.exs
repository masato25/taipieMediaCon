defmodule TaipieMediaCon.Repo.Migrations.CreateAvatar do
  use Ecto.Migration

  def change do
    create table(:avatar) do
      add :name, :string
      add :status, :string, defualt: "stop"
      add :last_exected_time, :datetime, default: nil
      add :descript, :string, default: nil

      timestamps()
    end

  end
end
