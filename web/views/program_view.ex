defmodule TaipieMediaCon.ProgramView do
  use TaipieMediaCon.Web, :view

  def render("index.json", %{program: program}) do
    %{data: render_many(program, TaipieMediaCon.ProgramView, "program.json")}
  end

  def render("show.json", %{program: program}) do
    %{data: render_one(program, TaipieMediaCon.ProgramView, "program.json")}
  end

  def render("program.json", %{program: program}) do
    %{id: program.id,
      name: program.name,
      command: program.command,
      descript: program.descript,
      other: program.other}
  end
end
