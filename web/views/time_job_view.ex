defmodule TaipieMediaCon.TimeJobView do
  use TaipieMediaCon.Web, :view

  def render("list.json", %{time_job: time_job}) do
    %{data: time_job}
  end

end
