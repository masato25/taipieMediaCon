defmodule TaipieMediaCon.TimeJobControllerTest do
  use TaipieMediaCon.ConnCase

  alias TaipieMediaCon.TimeJob
  @valid_attrs %{end_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, program_name: "some content", start_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok,
      conn: put_req_header(conn, "accept", "application/json"),
      host: "localhost:4000",
      jshead: [{"Content-Type", "application/json"}],
    }
  end

  test "list all time_job", %{host: host}  do
    resp = HTTPoison.get! "#{host}/api/time_jobs_list"
    jso = Poison.decode!(resp.body)
    assert Enum.count(jso["data"]) >= 0
  end

  # test "copyHourData", %{host: host, jshead: jshead} do
  #   #get sample data
  #   # resp = HTTPoison.get! "#{host}/api/time_jobs_list_help?start_time=#{1492714800}&end_time=#{1492718400}"
  #   # jso = Poison.decode!(resp.body)
  #   jbody = Poison.encode!(%{start_time: 1492884000, end_time: 1492887600, copy_next_h: 2 })
  #   resp = HTTPoison.post!("#{host}/api/time_jobs_copy_hour", jbody, jshead)
  #   # jso = Poison.decode!(resp.body)
  #   IO.inspect resp
  # end

  # test "copyHourData", %{host: host, jshead: jshead} do
  #   #get sample data
  #   resp = HTTPoison.get! "#{host}/api/time_jobs_list_help?start_time=#{1492704000}&end_time=#{1492790400}"
  #   jso = Poison.decode!(resp.body)
  #   jbody = Poison.encode!(%{data:  jso["data"], copy_next_d: 1})
  #   resp = HTTPoison.post!("#{host}/api/time_jobs_copy_day", jbody, jshead)
  #   # jso = Poison.decode!(resp.body)
  #   IO.inspect resp
  # end

  test "delete a time range", %{host: host, jshead: jshead} do
    HTTPoison.delete("#{host}/api/time_jobs_delete_date?from_time=#{1492704000}&to_time=#{1492790400 + (86400 * 3)}")
  end
end
