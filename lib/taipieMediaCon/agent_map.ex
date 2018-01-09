defmodule TaipieMediaCon.AgentMap do
  require Logger

  alias TaipieMediaCon.Repo
  import Ecto.Query
  alias TaipieMediaCon.Program
  alias TaipieMediaCon.TimeJob
  use GenServer

  @tablename :agents
  def start_link do
    GenServer.start_link(__MODULE__, [], [name: AgentMap])
  end

  def init(msg) do
    # TODO: need reset all connection
    # create named table for agents list
    :ets.new(@tablename, [:set, :named_table])
    {:ok, msg}
  end

  def insert(s, obj) do
    GenServer.call(s, {:insert, obj})
  end

  def handle_call({:insert, obj}, _from, objs) do
    :ets.insert(@tablename, obj)
    {:reply, {:ok}, objs}
  end

  def lookup(s, obj) do
    GenServer.call(s, {:lookup, obj})
  end

  def handle_call({:lookup, obj}, _form, objs) do
    record = :ets.lookup(@tablename, obj)
    {:reply, {:ok, record}, objs}
  end

  def keys(s) do
    GenServer.call(s, {:keys})
  end

  def handle_call({:keys}, _form, objs) do
    records = :ets.match(@tablename, :"$1")
    {:reply, {:ok, records}, objs}
  end

  def delete(s, obj) do
    GenServer.cast(s, {:delete, obj})
  end

  def handle_cast({:delete, obj}, objs) do
    :ets.delete(@tablename, obj)
    {:noreply, obj}
  end

end
