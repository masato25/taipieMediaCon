defmodule TaipieMediaCon.ProgramTest do
  use TaipieMediaCon.ModelCase

  alias TaipieMediaCon.Program

  @valid_attrs %{command: "some content", descript: "some content", name: "some content", other: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Program.changeset(%Program{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Program.changeset(%Program{}, @invalid_attrs)
    refute changeset.valid?
  end
end
