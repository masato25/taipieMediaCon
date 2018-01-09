defmodule TaipieMediaCon.RoomChannel do
  use Phoenix.Channel
  require Logger
  alias TaipieMediaCon.DBHelp.AvatarHelper

  def join("room:lobby:" <> uname, params, socket) do
    # get info passed from client
    name = Map.get(params, "name")
    jobName = Map.get(params, "job_name")
    jobRun = Map.get(params, "job_run")
    #{:ok, vbool} = GenServer.call(AgentMap, {:lookup, name})
    #if vbool == [] do
    cond do
      # check avatar is created?
      !AvatarHelper.clientExist(name) ->
        {:error, %{message: "avatar not existing, please check it"}}
      # for first time connection using
      !jobRun ->
        GenServer.call(AgentMap, {:insert, {name, socket} })
        AvatarHelper.startAvatar(name)
      true ->
        Logger.info("system unexcpet")
        # do nothing
    end

    if AvatarHelper.clientExist(name) do
      a1 = AvatarHelper.runningJob(name)
      # for reconnection, if current running task is not equals expect termnate it!
      if a1 != nil && Map.get(a1, :program_name) != jobName do
        AvatarHelper.pauseAvatar(name)
        TaipieMediaCon.Endpoint.broadcast("room:lobby:" <> name, "stop", %{command: "kill -9 aaa"})
      end
      socket = socket
                |> assign(:name, name)
      {:ok, %{message: "hello"}, socket}
    end
    #else
    #{:ok, %{message: "hello"}, socket}
    #end
  end

  def join("room:" <> _private_rooom_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  intercept ["user_joined", "new_msg"]

  def handle_in("new_msg", params, socket) do
    Logger.info("socket: #{inspect socket}")
    #1..5000 |> Enum.each( fn a ->
      #Process.sleep(2000)
      #push socket, "new_msg", %{body: Map.get(params, "body"), time: :os.system_time(:second), count: a, params: params}
      #end)
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

  def terminate(msg, socket) do
    name = socket.assigns[:name]
    GenServer.cast(AgentMap, {:delete, name})
    AvatarHelper.stopAvatar(name)
    {:shutdown, :left}
  end
end
