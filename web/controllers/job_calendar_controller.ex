defmodule TaipieMediaCon.JobCalendarController do
  use TaipieMediaCon.Web, :controller
  alias TaipieMediaCon.PageController, as: Auth
  alias TaipieMediaCon.JobCalendar
  alias TaipieMediaCon.JobTemplate

  def index(conn, _params) do
    if Auth.session_check(conn) do
      conn |>
      put_layout("f_calendar.html") |>
      render("index.html")
    else
      redirect conn, to: "/login"
    end
  end

  def indexv2(conn, %{"id" => id}) do
    job_template = Repo.all(from j in JobTemplate, where: j.id == ^id)
    # if no this template will return to template list
    if Enum.count(job_template) == 0 do
      redirect(conn, to: "/template")
    end
    if Auth.session_check(conn) do
      conn |>
      put_layout("f_calendar.html") |>
      render("index.html")
    else
      redirect conn, to: "/login"
    end
  end

end
