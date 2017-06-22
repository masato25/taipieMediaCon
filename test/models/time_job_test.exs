defmodule TaipieMediaCon.TimeJobTest do
  use TaipieMediaCon.ModelCase

  alias TaipieMediaCon.TimeJob

  @valid_attrs %{end_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, program_name: "some content", start_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
  @invalid_attrs %{}

  # test "changeset with valid attributes" do
  #   changeset = TimeJob.changeset(%TimeJob{}, @valid_attrs)
  #   assert changeset.valid?
  # end
  #
  # test "changeset with invalid attributes" do
  #   changeset = TimeJob.changeset(%TimeJob{}, @invalid_attrs)
  #   refute changeset.valid?
  # end
end
