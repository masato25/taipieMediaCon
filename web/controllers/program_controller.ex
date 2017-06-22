defmodule TaipieMediaCon.ProgramController do
  require Logger
  use TaipieMediaCon.Web, :controller
  alias TaipieMediaCon.PageController, as: Auth
  alias TaipieMediaCon.Program

  def indexhtml(conn, _params) do
    if Auth.session_check(conn) do
      conn |>
        put_layout("program_page.html") |>
        render("index.html")
    else
      redirect conn, to: "/login"
    end
  end

  def index(conn, _params) do
    program = Repo.all(Program)
    render(conn, "index.json", program: program)
  end

  def create(conn, %{"program" => program_params}) do
    changeset = Program.changeset(%Program{}, program_params)

    case Repo.insert(changeset) do
      {:ok, program} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", program_path(conn, :show, program))
        |> render("show.json", program: program)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(TaipieMediaCon.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    program = Repo.get!(Program, id)
    render(conn, "show.json", program: program)
  end

  def update(conn, %{"id" => id, "program" => program_params}) do
    program = Repo.get!(Program, id)
    changeset = Program.changeset(program, program_params)

    case Repo.update(changeset) do
      {:ok, program} ->
        render(conn, "show.json", program: program)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(TaipieMediaCon.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    program = Repo.get!(Program, id)

    ptmp = %{id: program.id, name: program.name}
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(program)

    conn |>
    json %{ message: "deleted", data: ptmp }
  end

  def agents(conn, _) do
    {:ok, keys} = GenServer.call(AgentMap, {:keys})
    keys = keys |> Enum.map(&(elem(hd(&1), 0)))
    json(conn, %{machines: keys})
  end

end
