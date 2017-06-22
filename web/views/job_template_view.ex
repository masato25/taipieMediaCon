defmodule TaipieMediaCon.JobTemplateView do
  use TaipieMediaCon.Web, :view

  def render("index.json", %{job_template: job_template}) do
    %{data: render_many(job_template, TaipieMediaCon.JobTemplateView, "job_template.json")}
  end

  def render("show.json", %{job_template: job_template}) do
    %{data: render_one(job_template, TaipieMediaCon.JobTemplateView, "job_template.json")}
  end

  def render("job_template.json", %{job_template: job_template}) do
    %{id: job_template.id,
      name: job_template.name}
  end

  def render("error.json", %{changeset: changeset}) do
    errMsgs = changeset.errors |> Enum.map(fn o ->
      field = elem(o, 0)
      errmsg = elem(o, 1) |> elem(0)
      "#{field}: #{errmsg}"
    end) |> Enum.join(", ")
    %{error: errMsgs}
  end

end
