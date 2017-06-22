defmodule TaipieMediaCon.TimeJob do
  use TaipieMediaCon.Web, :model
  require Logger
  @derive {Poison.Encoder, only: [:id, :start_time, :end_time, :program_name, :job_template_id]}
  schema "time_job" do
    field :start_time, Ecto.DateTime
    field :end_time, Ecto.DateTime
    belongs_to :program, TaipieMediaCon.Program
    belongs_to :job_template, TaipieMediaCon.JobTemplate
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    params2 = converTs(params)
    struct
    |> cast(params2, [:start_time, :end_time, :program_id, :job_template_id])
    |> validate_required([:start_time, :end_time, :program_id, :job_template_id])
  end

  def converAsApiObj(o) do
    Logger.info("converAsApiObj #{inspect Map.get(o, :program)}")
    start_time = dateTimeToTimestamp(Map.get(o, :start_time))
    end_time = dateTimeToTimestamp(Map.get(o, :end_time))
    program_id = Map.get(o, :program_id)
    program_name = Map.get(o, :program_name)
    job_template_id = Map.get(o, :job_template_id)
    id = Map.get(o, :id)
    %{start_time: start_time, end_time: end_time, title: program_name, id: id, job_template_id: job_template_id}
  end

  defp converTs(params) do
    if Map.has_key?(params, "start_time") do
      if is_integer(Map.get(params, "start_time")) do
        st = Ecto.DateTime.from_unix!(Map.get(params, "start_time"), :second)
        params = Map.put(params, "start_time",
                         %{"year" => "#{st.year}", "month" => "#{st.month}", "day" => "#{st.day}", "hour" => "#{st.hour}", "minute" => "#{st.min}"})
      end
    end
    if Map.has_key?(params, "end_time") do
      if is_integer(Map.get(params, "end_time")) do
        et = Ecto.DateTime.from_unix!(Map.get(params, "end_time"), :second)
        params = Map.put(params, "end_time",
                         %{"year" => "#{et.year}", "month" => "#{et.month}", "day" => "#{et.day}", "hour" => "#{et.hour}", "minute"=> "#{et.min}"})
      end
    end
    Logger.debug("will return params: #{inspect params}")
    params
  end

  defp dateTimeToTimestamp(dt) do
    :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(dt)) |> Kernel.-(62167219200)
  end

end
