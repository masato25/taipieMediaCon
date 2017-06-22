defmodule TaipieMediaCon.Program do
  use TaipieMediaCon.Web, :model

  schema "program" do
    field :name, :string
    field :command, :string
    field :descript, :string
    field :other, :string
    has_many :time_job, TaipieMediaCon.TimeJob, on_delete: :delete_all, on_replace: :delete
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :command, :descript, :other])
    |> validate_required([:name, :command])
  end
end
