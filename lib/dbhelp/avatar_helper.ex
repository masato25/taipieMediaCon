defmodule TaipieMediaCon.DBHelp.AvatarHelper do
  alias TaipieMediaCon.Avatar
  alias TaipieMediaCon.TimeJob
  alias TaipieMediaCon.Program
  alias TaipieMediaCon.Repo
  import Ecto.Query, only: [from: 2]
  require Logger

  def clientExist(name) do
    avatar = Repo.all(from t in Avatar,
    where: t.name == ^name)
    if Enum.count(avatar) == 0 do
      false
    else
      true
    end
  end

  def runningJob(name) do
    avatar = Repo.all(from t in Avatar,
    where: t.name == ^name) |> hd
    if avatar.time_job_id == nil do
      nil
    else
      o = Repo.all(
        from tj in TimeJob,
        join: p in Program,
        where: tj.id == ^avatar.time_job_id and p.id == tj.program_id,
        limit: 1,
        select: {p.name, tj.start_time, tj.end_time}
      ) |> hd()
      {pname, tstart_time, tend_time} = o
      %{program_name: pname, t_start_time: tstart_time, t_end_time: tend_time, avatar: avatar}
    end
  end

  def startAvatar(name) do
    avatar = Repo.all(from t in Avatar,
    where: t.name == ^name) |> hd
    changeset = Avatar.changeset(avatar, %{"status": "start", "last_exected_time": Timex.now, "time_job_id": nil})
    Repo.update(changeset)
  end

  def stopAvatar(name) do
    avatar = Repo.all(from t in Avatar,
    where: t.name == ^name) |> hd
    changeset = Avatar.changeset(avatar, %{"status": "stop", "last_exected_time": Timex.now, "time_job_id": nil})
    Repo.update(changeset)
  end

  def runAvatar(name, time_job_id) do
    avatar = Repo.all(from t in Avatar,
    where: t.name == ^name) |> hd
    changeset = Avatar.changeset(avatar, %{"status": "run", "last_exected_time": Timex.now, "time_job_id": time_job_id})
    Repo.update(changeset)
  end

  def pauseAvatar(name) do
    avatar = Repo.all(from t in Avatar,
    where: t.name == ^name) |> hd
    changeset = Avatar.changeset(avatar, %{"status": "pause", "last_exected_time": Timex.now, "time_job_id": nil})
    Repo.update(changeset)
  end

  def updateTimejob(name, time_job_id) do
    avatar = Repo.all(from t in Avatar,
    where: t.name == ^name) |> hd
    changeset = Avatar.changeset(avatar, %{"time_job_id": time_job_id})
    Repo.update(changeset)
  end

end
