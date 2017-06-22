defmodule TaipieMediaCon.JobTemplate do
  use TaipieMediaCon.Web, :model

  schema "job_template" do
    field :name, :string

    has_many :avatar, TaipieMediaCon.Avatar, on_delete: :nilify_all
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name, message: "名稱重複")
  end
end
