defmodule TaipieMediaCon.JobTemplateTest do
  use TaipieMediaCon.ModelCase

  alias TaipieMediaCon.JobTemplate

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = JobTemplate.changeset(%JobTemplate{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = JobTemplate.changeset(%JobTemplate{}, @invalid_attrs)
    refute changeset.valid?
  end
end
