require Logger

defmodule Player do
  @moduledoc false
  


  use GenServer

  def start_link(id, socket) do
    name = "player_#{id}"
    state = %{id: id, socket: socket}
    GenServer.start_link(__MODULE__, state, [{:name, {:global, name}}])
  end

  def get_id(pid) do
    GenServer.call(pid, {:get_id})
  end

  def get_ship(pid) do
    GenServer.call(pid, {:get_ship})
  end

  def handle_data(pid, data) do
    GenServer.call(pid, {:handle_data, data})
  end

  def send_message(pid, message) do
    GenServer.call(pid, {:send_message, message})
  end

  # Server callbacks

  def init(state) do
    Logger.info "Starting player #{state[:id]}"
    {:ok, ship} = Ship.start_link(state[:id], 42)
    Logger.info "Starting player #{state[:id]} - created ship"
    state = Map.put(state, :ship, ship)
    {:ok, state}
  end

  def handle_call({:get_id}, _from, state) do
    {:reply, state[:id], state}
  end

  def handle_call({:get_ship}, _from, state) do
    {:reply, state[:ship], state}
  end

  def handle_call({:handle_data, data}, _from, state) do
    solarsystem = GenServer.whereis({:global, "ex1"})
    message = "Message from #{state[:id]}: #{data}"
    Solarsystem.broadcast(solarsystem, message)
    {:reply, :ok, state}
  end

  def handle_call({:send_message, message}, _from, state) do
    socket = state[:socket]
    :gen_tcp.send(socket, message)
    {:reply, :ok, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end