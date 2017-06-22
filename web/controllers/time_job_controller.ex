defmodule TaipieMediaCon.TimeJobController do
  use TaipieMediaCon.Web, :controller
  require Logger
  alias TaipieMediaCon.TimeJob
  alias TaipieMediaCon.Avatar
  alias TaipieMediaCon.Program
  alias TaipieMediaCon.PageController, as: Auth

  def index(conn, _params) do
    time_job = Repo.all(TimeJob)
    render(conn, "index.html", time_job: time_job)
  end

  def new(conn, _params) do
    changeset = TimeJob.changeset(%TimeJob{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"time_job" => time_job_params}) do
    #%{"end_time" => %{"day" => "1", "hour" => "0", "minute" => "0", "month" => "1", "year" => "2017"}, "program_name" => "www", "start_time" => %{"day" => "1", "hour" => "0", "minute" => "0", "month" => "1", "year" => "2017"}}
    changeset = TimeJob.changeset(%TimeJob{}, time_job_params)
    Logger.info("#{inspect time_job_params}")
    case Repo.insert(changeset) do
      {:ok, _time_job} ->
        conn
        |> put_flash(:info, "Time job created successfully.")
        |> redirect(to: time_job_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    if Auth.session_check(conn) do
      time_job = Repo.get!(TimeJob, id)
      render(conn, "show.html", time_job: time_job)
    else
      redirect conn, to: "/login"
    end
  end

  def edit(conn, %{"id" => id}) do
    time_job = Repo.get!(TimeJob, id)
    changeset = TimeJob.changeset(time_job)
    render(conn, "edit.html", time_job: time_job, changeset: changeset)
  end

  def update(conn, %{"id" => id, "time_job" => time_job_params}) do
    time_job = Repo.get!(TimeJob, id)
    changeset = TimeJob.changeset(time_job, time_job_params)

    case Repo.update(changeset) do
      {:ok, time_job} ->
        conn
        |> put_flash(:info, "Time job updated successfully.")
        |> redirect(to: time_job_path(conn, :show, time_job))
      {:error, changeset} ->
        render(conn, "edit.html", time_job: time_job, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id, "job_template_id" => job_template_id}) do
    time_job = Repo.all(from t in TimeJob, where: t.id == ^id and t.job_template_id == ^job_template_id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(time_job)

    conn
    |> put_flash(:info, "Time job deleted successfully.")
    |> redirect(to: time_job_path(conn, :index))
  end

  ####################
  # json controllers #
  # **************** #

  def list(conn, %{"template_id" => template_id}) do
    template_id = String.to_integer(template_id)
    time_job = Repo.all(
      from t in TimeJob,
      join: p in Program,
      where: t.program_id == p.id and t.job_template_id == ^template_id,
      select: { t.id, t.start_time, t.end_time, p.name, p.id }
    ) |>
      Enum.map(fn o ->
        {tid, start_time, end_time, program_name, pid} = o
        o2 = %{start_time: start_time, end_time: end_time, program_name: program_name, id: tid, program_id: pid}
        Logger.info("list #{inspect o}")
        TimeJob.converAsApiObj(o2)
      end)
    conn |>
    json(%{"data": time_job})
  end

  def listp(conn, %{"start_time" => start_time, "end_time" => end_time, "template_id" => template_id}) do
    time_job = getDataWithTimeInfo(String.to_integer(start_time), String.to_integer(end_time), String.to_integer(template_id))
    conn |>
    json(%{"data": time_job})
  end

  def jdelete(conn, %{"id" => id}) do
    time_job = Repo.get!(TimeJob, id)

    ptmp = %{id: time_job.id}
    if checkrunningJob(ptmp.id) != 0 do
      json(conn, %{errors: "無法刪除正在運行的程序"})
    end

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    case Repo.delete(time_job) do
      {:ok, struct}       ->
        conn |>
        json %{ message: "deleted", data: ptmp }
      {:error, changeset} ->
        conn |>
        json %{ error: "刪除失敗, 請重試" }
    end
  end

  def jdelete_d_date(conn, %{"from_time" => from_time, "to_time" => to_time, "job_template_id" => template_id}) do
    template_id = String.to_integer(template_id)
    deleted_list = []
    deleted_list = Repo.all(
      from t in TimeJob,
      where: t.start_time >= ^DateTime.from_unix!(String.to_integer(from_time), :second) and t.end_time <= ^DateTime.from_unix!(String.to_integer(to_time), :second) and t.job_template_id == ^template_id
    ) 

    deleted_list |> Enum.map(fn o ->
        ptmp = Map.get(o, :id)
        if checkrunningJob(ptmp) != 0 do
          json(conn, %{errors: "無法刪除正在運行的程序"})
        end
        case Repo.delete(o) do
          {:ok, struct}       ->
            Logger.debug("date is deleted #{inspect struct}")
            ptmp
          {:error, changeset} ->
            Logger.debug("date is deleted failed #{inspect changeset}")
            json(conn, %{errors: changeset.errors})
        end
      end) |>
      Enum.filter(&(&1 != nil))
    conn |>
    json %{ message: "deleted all date", data: deleted_list }
  end

  defp checkrunningJob(tid) do
    Repo.all(
      from a in Avatar,
      where: a.time_job_id == ^tid) |> Enum.count()
  end

  def jcreate(conn, %{"time_job" => time_job_params}) do
    changeset = %{}
    try do
      changeset = TimeJob.changeset(%TimeJob{}, time_job_params)
      cond do
        checkTimePeriod(changeset) ->
          conn |>
            json(%{
              "error": "這個時段已經設定過了"
            })
        changeset.errors != [] ->
          conn |>
            json(%{
              "error": "#{inspect changeset.errors}"
            })
        true ->
          case Repo.insert(changeset) do
            {:ok, time_job} ->
              program_name = Repo.all(
                from p in Program,
                where: p.id == ^Map.get(time_job, :program_id),
                select: {p.name}
              ) |> hd |> elem(0)
              time_job = Map.put(time_job, :program_name, program_name)
              Logger.info("sss #{inspect time_job}")
              conn |>
                json(%{
                  "info": "展示工作新增成功",
                  "event": TimeJob.converAsApiObj(time_job)
                })
            {:error, changeset} ->
              conn |>
                json(%{
                  "error": "展示工作新增失敗,請重試",
                  "ecto_obj": changeset
                })
          end
      end
    catch
      err ->
        conn |>
        json(%{
          "error": "#{inspect err}"
        })
    end

  end


  def copyHoursData(conn, %{"start_time" => start_time, "end_time" => end_time, "copy_next_h" => copy_next_h, "job_template_id" => template_id}) do
    time_job = getDataWithTimeInfo(start_time, end_time, template_id) |>
      Enum.map(fn o ->
        #conver atom to string keys
        for {key, value} <- o, into: %{}, do: {Atom.to_string(key), value}
      end)
    Logger.info("copy_time_job: #{Enum.count(time_job)}")
    nowData = time_job |>
      Enum.map(fn o ->
        for m <- 1..copy_next_h do
          newed = Map.get(o, "end_time") + (3600*m)
          o = Map.put(o, "end_time", newed)
          startd = Map.get(o, "start_time") + (3600*m)
          o = Map.put(o, "start_time", startd)
          changeset = TimeJob.changeset(%TimeJob{}, o)
          if !checkTimePeriod(changeset) do
            case  Repo.insert(changeset) do
              {:ok, time_job} ->
                program_name = Repo.all(
                  from p in Program,
                  where: p.id == ^Map.get(time_job, :program_id),
                  select: {p.name}
                ) |> hd |> elem(0)
                time_job = Map.put(time_job, :program_name, program_name)
                TimeJob.converAsApiObj(time_job)
              {:error, changeset} ->
                json(conn, %{errors: changeset.errors})
            end
          else
            nil
          end
        end
      end)
      nowData = nowData |>
        Enum.flat_map(&(&1)) |>
        Enum.filter(&(&1 != nil))
    conn |>
    json(%{data: nowData})
  end

  def copyDayData(conn, %{"start_time" => start_time, "end_time" => end_time, "copy_to" => copy_to, "time_diff" => time_diff, "job_template_id" => template_id}) do
    time_job = getDataWithTimeInfo(start_time, end_time, template_id) |>
      Enum.map(fn o ->
        #conver atom to string keys
        for {key, value} <- o, into: %{}, do: {Atom.to_string(key), value}
      end)
    nowData = time_job |>
      Enum.map(fn o ->
        newed = Map.get(o, "end_time") + (time_diff)
        o = Map.put(o, "end_time", newed)
        startd = Map.get(o, "start_time") + (time_diff)
        o = Map.put(o, "start_time", startd)
        changeset = TimeJob.changeset(%TimeJob{}, o)
        if !checkTimePeriod(changeset) do
          case  Repo.insert(changeset) do
            {:ok, time_job} ->
              program_name = Repo.all(
                from p in Program,
                where: p.id == ^Map.get(time_job, :program_id),
                select: {p.name}
              ) |> hd |> elem(0)
              time_job = Map.put(time_job, :program_name, program_name)
              TimeJob.converAsApiObj(time_job)
            {:error, changeset} ->
              nil
          end
        else
          nil
        end
      end)
    nowData = nowData |>
      Enum.filter(&(&1 != nil))
    conn |>
    json(%{data: nowData})
  end

  defp checkTimePeriod(tmpo) do
    o = Map.get(tmpo, :changes)
    stime = Map.get(o, :start_time)
    etime = Map.get(o, :end_time)
    res = Repo.all(
            from tj in TimeJob,
            where: (^stime >= tj.start_time and ^stime < tj.end_time) or (^etime > tj.start_time and ^etime <= tj.end_time )
          )
    Enum.count(res) != 0
  end

  defp dateTimeToTimestamp(dt) do
    :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(dt)) |> Kernel.-(62167219200)
  end

  defp convertTsToDateWithTimeZone(ts) do

    original = Timex.now
    timezone = Timex.Timezone.get("Asia/Taipei", original)
    Timex.from_unix(ts) |> Timex.Timezone.convert(timezone) |> Timex.to_erl()
    
  end

  defp getDataWithTimeInfo(start_time, end_time, template_id) do
    bstate_time = Ecto.DateTime.from_unix!(start_time, :second)
    estate_time = Ecto.DateTime.from_unix!(end_time, :second)

    a1 = Repo.all(
      from t in TimeJob,
      where: t.start_time >= ^bstate_time and t.end_time <= ^estate_time and t.job_template_id == ^template_id,
      select: {t.id, t.start_time, t.end_time, t.program_id, t.job_template_id}
    )
    a1 |> Enum.map(fn o ->
        {tid, start_time, end_time, program_id, job_template_id} = o
        %{start_time: dateTimeToTimestamp(start_time), end_time: dateTimeToTimestamp(end_time), program_id: program_id, id: tid, job_template_id: job_template_id}
      end)
  end
end
