defmodule TaipieMediaCon.AvatarControllerTest do
  use TaipieMediaCon.ConnCase

  alias TaipieMediaCon.Avatar
  @valid_attrs %{descript: "some content", last_exected_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, name: "some content", status: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, avatar_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    avatar = Repo.insert! %Avatar{}
    conn = get conn, avatar_path(conn, :show, avatar)
    assert json_response(conn, 200)["data"] == %{"id" => avatar.id,
      "name" => avatar.name,
      "status" => avatar.status,
      "last_exected_time" => avatar.last_exected_time,
      "descript" => avatar.descript}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, avatar_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, avatar_path(conn, :create), avatar: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Avatar, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, avatar_path(conn, :create), avatar: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    avatar = Repo.insert! %Avatar{}
    conn = put conn, avatar_path(conn, :update, avatar), avatar: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Avatar, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    avatar = Repo.insert! %Avatar{}
    conn = put conn, avatar_path(conn, :update, avatar), avatar: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    avatar = Repo.insert! %Avatar{}
    conn = delete conn, avatar_path(conn, :delete, avatar)
    assert response(conn, 204)
    refute Repo.get(Avatar, avatar.id)
  end
end
