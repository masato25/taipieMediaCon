defmodule TaipieMediaCon.AvatarView do
  use TaipieMediaCon.Web, :view
  alias TaipieMediaCon.JobTemplate
  alias TaipieMediaCon.Repo
  alias Timex.Timezone
  alias TaipieMediaCon.DBHelp.AvatarHelper 

  def render("index.json", %{avatar: avatar}) do
    %{data: render_many(avatar, TaipieMediaCon.AvatarView, "avatar.json")}
  end

  def render("show.json", %{avatar: avatar}) do
    %{data: render_one(avatar, TaipieMediaCon.AvatarView, "avatar.json")}
  end

  def render("avatar.json", %{avatar: avatar}) do
    jobt = Repo.get!(JobTemplate, avatar.job_template_id)
    jt = AvatarHelper.runningJob(avatar.name)
    last_exected_time = nil
    if avatar.last_exected_time != nil do
      timezone = Timezone.get("Asia/Taipei", Timex.now)
      last_exected_time = convertEctoDateWithTimeZone(avatar.last_exected_time)
    end

    if jt == nil do
      %{id: avatar.id,
        name: avatar.name,
        status: avatar.status,
        descript: avatar.descript,
        last_exected_time: last_exected_time,
        job_template_id: avatar.job_template_id,
        template_name: jobt.name,
        time_job_id: '',
      }
    else
      stime = convertEctoDateWithTimeZone(Map.get(jt, :t_start_time))
      etime = convertEctoDateWithTimeZone(Map.get(jt, :t_end_time))
      %{id: avatar.id,
        name: avatar.name,
        status: avatar.status,
        descript: avatar.descript,
        last_exected_time: last_exected_time,
        job_template_id: jobt.id,
        template_name: jobt.name,
        time_job_id: "#{Map.get(jt, :program_name)} [#{stime} ~ #{etime}]",
      }
    end
  end

  defp convertEctoDateWithTimeZone(d) do
    timezone = Timezone.get("Asia/Taipei", Timex.now)
    Timezone.convert(convertDateTime(d), timezone) |> Timex.format!("%F %T", :strftime)
  end

  def convertDateTime(s) do
    Ecto.DateTime.to_erl(s) |> NaiveDateTime.from_erl! |>  DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix |> Timex.from_unix
  end
end
