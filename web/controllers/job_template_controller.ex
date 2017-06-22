defmodule TaipieMediaCon.JobTemplateController do
  use TaipieMediaCon.Web, :controller
  require Logger
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
    job_template = Repo.get!(JobTemplate, id)

    jtmtp = %{id: job_template.id, name: job_template.name}
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(job_template)

    json(conn, %{message: "deleted", data: jtmtp})
  end
end
