defmodule TaipieMediaCon.JobMag do
  require Logger

  alias TaipieMediaCon.Repo
  import Ecto.Query
  alias TaipieMediaCon.Program
  alias TaipieMediaCon.TimeJob
  alias TaipieMediaCon.Avatar
  alias TaipieMediaCon.DBHelp.AvatarHelper 

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(msg) do
    :ets.new(:jstatus, [:set, :named_table])
    schedule_work()
    :ets.insert(:jstatus, {"status", "stop"})
    
    talk2()
    {:ok, msg}
  end

  defp dateTimeToTimestamp(dt) do
    :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(dt)) |> Kernel.-(62167219200)
    # |> converUnixTs
  end

  defp converUnixTs(unixt) do
    datetime = Timex.from_unix(unixt, 0)
    timezone = Timex.Timezone.get("Asia/Taipei", Timex.now())
    Timex.Timezone.convert(datetime, timezone)
  end

  defp converTs(datetime) do
    timezone = Timex.Timezone.get("Asia/Taipei", Timex.now())
    Timex.Timezone.convert(datetime, timezone)
  end

  def getNewJob(template_id, currentTime) do
    o = Repo.all(
      from t in TimeJob,
      join: p in Program,
      where: (t.start_time <= ^currentTime and t.end_time > ^currentTime ) and t.job_template_id == ^template_id and p.id == t.program_id,
      order_by: [asc: t.start_time],
      limit: 1,
      select: {t.id, t.start_time, t.end_time, p.name, p.command}
    )
    if o == [] do
      nil
    else
      {id, st, et, pname, pcomm} = hd(o)
      %{id: id, name: pname, command: pcomm, start_time: dateTimeToTimestamp(st), end_time: dateTimeToTimestamp(et)}
    end
  end

  def findStartedAgents() do
    Repo.all(from at in Avatar, where: at.status == "start" or at.status == "pause" or at.status == "run")
  end

  def talk2() do
    # Logger.info(":ets.lookup(:jstatus, status): #{inspect :ets.lookup(:jstatus, "status")}")
    agents = findStartedAgents()
    runAgents = agents |> Enum.filter(fn at -> 
      flag = false
      if at.status == "run" && at.time_job_id != nil do
        flag = true
      end 
      if at.status == "start" && at.time_job_id != nil do
        flag = true
      end
      flag
    end)
    pauseAgents = agents |> Enum.filter(fn at -> 
      flag = false
      if at.status == "pause" do
        flag = true
      end
      if at.status == "start" && at.time_job_id == nil do
        flag = true
      end
      flag
    end)
    Logger.info("runAgents: #{Enum.count(runAgents)}, pauseAgents: #{Enum.count(pauseAgents)}")

    currentTime = Ecto.DateTime.from_unix!(DateTime.to_unix(Timex.now(), :second), :second)
    pauseAgents |> Enum.each(fn at ->
      newJob = getNewJob(at.job_template_id, currentTime)
      Logger.info("newJob is null? #{newJob == nil}")
      if newJob != nil  do
        AvatarHelper.runAvatar(at.name, newJob.id)
        TaipieMediaCon.Endpoint.broadcast("room:lobby:" <> at.name, "run", newJob)
      end
    end)
    runAgents |> Enum.each(fn at ->
      if at.time_job_id != nil do
        o = Repo.all(from t in TimeJob, where: t.id == ^at.time_job_id, limit: 1)
        cond do
          o == [] ->
            Logger.info("o == []")
            AvatarHelper.pauseAvatar(at.name)
            TaipieMediaCon.Endpoint.broadcast("room:lobby:" <> at.name, "stop", %{command: "kill -9 aaa"})
            Logger.debug("will delete")
          hd(o).end_time <= currentTime && hd(o).start_time < currentTime ->
            AvatarHelper.pauseAvatar(at.name)
            TaipieMediaCon.Endpoint.broadcast("room:lobby:" <> at.name, "stop", %{command: "kill -9 aaa"})
            Logger.debug("will delete")
          true ->
            # for debug
            Logger.info("#{IO.inspect hd(o).end_time} <= #{IO.inspect currentTime}")
            Logger.info("#{IO.inspect hd(o).start_time} <= #{IO.inspect currentTime}")
            #Logger.debug("do nothig")
            TaipieMediaCon.Endpoint.broadcast("room:lobby:" <> at.name, "continue", %{})
        end
      end
    end)
    #currentStatus = :ets.lookup(:jstatus, "status") |> hd
    #if elem(currentStatus, 1) == "stop" do
    #  o = getNewJob()
    #  Logger.debug("my o #{inspect o}")
    #  if o != nil and o.start_time <= DateTime.to_unix(Timex.now()) do
    #    Logger.debug("run job #{inspect o}")
    #    TaipieMediaCon.Endpoint.broadcast("room:lobby", "run", o)
    #    :ets.delete(:jstatus, "status")
    #    :ets.insert(:jstatus, {"status", "run", o})
    #  end
    #end
    #if elem(currentStatus, 1) == "run" do
    #  {_, "run" , obj} = currentStatus
    #  Logger.debug("my obj: #{inspect obj}")
    #  if obj.end_time <= DateTime.to_unix(Timex.now()) do
    #    Logger.debug("stop job #{inspect obj}")
    #    TaipieMediaCon.Endpoint.broadcast("room:lobby:m1", "stop", %{command: "kill -9 aaa"})
    #    :ets.delete(:jstatus, "status")
    #    :ets.insert(:jstatus, {"status", "stop"})
    #  else
    #    Logger.info("continue run job #{inspect obj}")
    #    TaipieMediaCon.Endpoint.broadcast("room:lobby:m1", "continue", obj)
    #  end
    #end
  end

  def handle_info(:talk2, state) do
    # Logger.info("will talke 2")
    talk2()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :talk2, (2 * 1000))
  end

  # def terminate(s,a) do
  #   Logger.info("terminate: #{inspect s}, #{inspect a}")
  # end
end
