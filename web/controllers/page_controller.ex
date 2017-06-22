defmodule TaipieMediaCon.PageController do
  use TaipieMediaCon.Web, :controller
  require Logger
  def index(conn, _params) do
    render conn, "index.html"
  end

  def login(conn, _params) do
    conn |>
    put_layout("login.html") |>
    render "login.html"
  end

  def logout(conn, _params) do
    conn |>
    delete_resp_cookie("token_key") |>
    redirect to: "/login"
  end

  def login_api(conn, %{"password" => password}) do
    matched = (String.to_charlist(password) == Application.get_env(:taipieMediaCon, :password))
    if matched do
      token_key = to_string(Application.get_env(:taipieMediaCon, :token_key))
      conn |>
      json %{status: "ok", token: token_key, matched: matched}
    else
      conn |>
      json %{status: "failed", matched: matched}
    end
  end

  def session_check(conn, %{"token": token}) do
    token_key = conn.cookies["token_key"] || ""
    matched = (to_string(Application.get_env(:taipieMediaCon, :token_key)) == token_key)
    if matched do
      conn |>
      json %{status: "ok"}
    else
      conn |>
      json %{status: "failed"}
    end
  end

  def session_check(conn) do
    token_key = conn.cookies["token_key"] || ""
    matched = (to_string(Application.get_env(:taipieMediaCon, :token_key)) == token_key)
  end

end
