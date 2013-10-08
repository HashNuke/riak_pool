defmodule RiakPool.RiakWorker do
  use GenServer.Behaviour
  @behaviour :poolboy_worker

  defrecord State, connection: nil, address: nil, port: nil, options: nil


  def start_link([address, port]) do
    :gen_server.start_link(__MODULE__, [address, port], [])
  end


  def start_link([address, port, options]) do
    :gen_server.start_link(__MODULE__, [address, port, options], [])
  end


  def init([address, port, options]) do
    :erlang.process_flag(:trap_exit, true)
    {:ok, connection} = :riakc_pb_socket.start_link(address, port, options)
    state = State.new(
      connection: connection,
      address:    address,
      port:       port,
      options:    options)

    {:ok, state}
  end


  def init([address, port]) do
    :erlang.process_flag(:trap_exit, true)
    {:ok, connection} = :riakc_pb_socket.start_link(address, port)
    state = State.new(connection: connection, address: address, port: port)
    {:ok, state}
  end


  def handle_call(:connection, _from, state) do
    {:reply, state.connection, state}
  end


  def handle_call({:run, worker_function}, _from, state) do
    result = :erlang.apply(worker_function, [state.connection])
    {:reply, result, state}
  end


  def handle_info(info, state) do
    IO.inspect "ERROR SAYS HI"
    IO.inspect info
    {:noreply, state.connection(:undefined)}
  end
end
