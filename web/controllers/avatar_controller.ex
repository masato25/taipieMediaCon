defmodule TaipieMediaCon.AvatarController do
  use TaipieMediaCon.Web, :controller
  alias TaipieMediaCon.PageController, as: Auth
  alias TaipieMediaCon.Avatar

  def indexhtml(conn, _params) do
    if Auth.session_check(conn) do
      conn |>
      put_layout("avatar.html") |>
     render("index.html")
    else
      redirect conn, to: "/login"
    end
  end

  def index(conn, _params) do
    avatar = Repo.all(Avatar)
    render(conn, "index.json", avatar: avatar)
  end

  def create(conn, %{"avatar" => avatar_params}) do
    changeset = Avatar.changeset(%Avatar{}, avatar_params)

    case Repo.insert(changeset) do
      {:ok, avatar} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", avatar_path(conn, :show, avatar))
        |> render("show.json", avatar: avatar)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(TaipieMediaCon.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    avatar = Repo.get!(Avatar, id)
    render(conn, "show.json", avatar: avatar)
  end

  def update(conn, %{"id" => id, "avatar" => avatar_params}) do
    # when update will clean time_job_id, because user may change templeate binging
    avatar_params = Map.put(avatar_params, "time_job_id", nil)
    avatar_params = Map.put(avatar_params, "status", "start")
    avatar = Repo.get!(Avatar, id)
    changeset = Avatar.changeset(avatar, avatar_params)

    case Repo.update(changeset) do
      {:ok, avatar} ->
        TaipieMediaCon.Endpoint.broadcast("room:lobby:" <> avatar.name, "stop", %{command: "kill -9 aaa"})
        render(conn, "show.json", avatar: avatar)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(TaipieMediaCon.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    avatar = Repo.get!(Avatar, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(avatar)

    send_resp(conn, :no_content, "")
  end
end
