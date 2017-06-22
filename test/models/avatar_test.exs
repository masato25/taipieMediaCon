defmodule TaipieMediaCon.AvatarTest do
  use TaipieMediaCon.ModelCase

  alias TaipieMediaCon.Avatar

  @valid_attrs %{descript: "some content", last_exected_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, name: "some content", status: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Avatar.changeset(%Avatar{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Avatar.changeset(%Avatar{}, @invalid_attrs)
    refute changeset.valid?
  end
end
