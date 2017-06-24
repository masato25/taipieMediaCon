defmodule TaipieMediaCon.JobTemplateController do
  use TaipieMediaCon.Web, :controller
  require Logger
  alias TaipieMediaCon.TimeJob
  alias TaipieMediaCon.Avatar
  alias TaipieMediaCon.JobTemplate
  alias TaipieMediaCon.PageController, as: Auth

  def indexhtml(conn, _params) do
    conn |>
    put_layout("job_template.html") |>
    render("index.html")
  end

  def index(conn, _params) do
    job_template = Repo.all(JobTemplate)
    render(conn, "index.json", job_template: job_template)
  end

  def create(conn, %{"job_template" => job_template_params}) do
    changeset = JobTemplate.changeset(%JobTemplate{}, job_template_params)

    case Repo.insert(changeset) do
      {:ok, job_template} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", job_template_path(conn, :show, job_template))
        |> render("show.json", job_template: job_template)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(TaipieMediaCon.JobTemplateView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    job_template = Repo.get!(JobTemplate, id)
    render(conn, "show.json", job_template: job_template)
  end

  def update(conn, %{"id" => id, "job_template" => job_template_params}) do
    job_template = Repo.get!(JobTemplate, id)
    changeset = JobTemplate.changeset(job_template, job_template_params)

    case Repo.update(changeset) do
      {:ok, job_template} ->
        render(conn, "show.json", job_template: job_template)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(TaipieMediaCon.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    ct = checkRunningJob(id)
    ct2 = checkBindingAvatar(id)
    cond do
      ct2 != 0 ->
        json(conn, %{errors: "此樣板還有應用端還在綁定, 請先解除才能刪除"}) 
      ct != 0 ->
        json(conn, %{errors: "還有程序正在運行中, 無法刪除"}) 
      true ->
        job_template = Repo.get!(JobTemplate, id)

        jtmtp = %{id: job_template.id, name: job_template.name}
        # Here we use delete! (with a bang) because we expect
        # it to always work (and if it does not, it will raise).
        Repo.delete!(job_template)

        json(conn, %{message: "deleted", data: jtmtp})
    end
  end

  def checkRunningJob(id) do
    ot = Repo.all(from a in Avatar, where: a.time_job_id > 0)
    ct = ot |> Enum.filter(fn o ->
      ot2 = Repo.all(from b in TimeJob, where: b.id == ^o.time_job_id and b.job_template_id == ^id)
      Enum.count(ot2) != 0
    end) |> Enum.count()
  end

  def checkBindingAvatar(tid) do
    ot = Repo.all(from a in Avatar, where: a.job_template_id == ^tid)
    ot |> Enum.count()
  end

end
