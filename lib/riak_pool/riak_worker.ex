defmodule RiakPool.RiakWorker do
  use GenServer.Behaviour
  @behaviour :poolboy_worker

  defrecord(State,
    connection: :undefined,
    address:    :undefined,
    port:       :undefined,
    options:    [],
    timer:      :undefined
  )


  def start_link([address, port]) do
    start_link([address, port, []])
  end


  def start_link([address, port, options]) do
    :gen_server.start_link(__MODULE__, [address, port, options], [])
  end


  def init([address, port, options]) do
    :erlang.process_flag(:trap_exit, true)
    state = State.new(
      address:    address,
      port:       port,
      options:    options)

    {:ok, connect(state)}
  end


  def handle_call({:run, worker_function}, _from, state) do
    result = :erlang.apply(worker_function, [state.connection])
    {:reply, result, state}
  end


  defp connect(state) do
    # First, cancel any timers
    if state.timer != :undefined do
      :erlang.cancel_timer(state.timer)
    end
    new_state = state.timer(:undefined)

    case :riakc_pb_socket.start_link(state.address, state.port, state.options) do
      {:ok, connection} ->
        connected_state = new_state.connection(connection)
      {:error, _reason} ->
        faulty_state = new_state.connection(:undefined)
        faulty_state.timer(:erlang.send_after(3000, self, :reconnect))
    end
  end


  def handle_info({:EXIT, _pid, reason}, state) do
    new_state = state.connection(:undefined)
    {:noreply, new_state.timer(:erlang.send_after(3000, self, :reconnect))}
  end


  def handle_info(:reconnect, state) do
    new_state = connect(state)
    {:noreply, new_state}
  end
end
