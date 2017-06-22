defmodule TaipieMediaCon.Avatar do
  use TaipieMediaCon.Web, :model
  
  schema "avatar" do
    field :name, :string
    field :status, :string
    field :last_exected_time, Ecto.DateTime
    field :descript, :string
    belongs_to :job_template, TaipieMediaCon.JobTemplate
    belongs_to :time_job, TaipieMediaCon.TimeJob

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :status, :last_exected_time, :descript, :job_template_id, :time_job_id])
    |> validate_required([:name])
    |> unique_constraint(:name, message: "名稱重複")
  end
end
