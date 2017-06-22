defmodule TaipieMediaCon.JobCalendar do
  use TaipieMediaCon.Web, :model

  schema "job_calendar" do

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
