defmodule TaipieMediaCon.JobTemplateControllerTest do
  use TaipieMediaCon.ConnCase

  alias TaipieMediaCon.JobTemplate
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, job_template_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    job_template = Repo.insert! %JobTemplate{}
    conn = get conn, job_template_path(conn, :show, job_template)
    assert json_response(conn, 200)["data"] == %{"id" => job_template.id,
      "name" => job_template.name}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, job_template_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, job_template_path(conn, :create), job_template: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(JobTemplate, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, job_template_path(conn, :create), job_template: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    job_template = Repo.insert! %JobTemplate{}
    conn = put conn, job_template_path(conn, :update, job_template), job_template: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(JobTemplate, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    job_template = Repo.insert! %JobTemplate{}
    conn = put conn, job_template_path(conn, :update, job_template), job_template: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    job_template = Repo.insert! %JobTemplate{}
    conn = delete conn, job_template_path(conn, :delete, job_template)
    assert response(conn, 204)
    refute Repo.get(JobTemplate, job_template.id)
  end
end
