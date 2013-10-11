defmodule RiakPool do
  use Supervisor.Behaviour


  def start_link(address, port, options) do
    :supervisor.start_link(__MODULE__, [address, port, options])
  end


  def start_link(address, port) do
    start_link(address, port, [])
  end


  def init([address, port, options]) do
    default_pool_options = [
      name: {:local, :riak_pool},
      worker_module: RiakPool.Worker,
      size: 5,
      max_overflow: 10
    ]

    pool_options = Dict.get(options, :pool_options, [])

    worker_args = [
      address,
      port,
      [
        retry_interval:     Dict.get(options, :retry_interval, 60) * 1000,
        connection_options: Dict.get(options, :connection_options, [])
      ]
    ]

    children = [
      :poolboy.child_spec(:riak_pool,
        Dict.merge(default_pool_options, pool_options),
        worker_args)
    ]

    supervise(children, strategy: :one_for_one)
  end


  @spec run((pid -> any)) :: any
  def run(worker_function) do
    :poolboy.transaction :riak_pool, fn(worker)->
      :gen_server.call(worker, {:run, worker_function})
    end
  end


  @doc """
  Used to create or update values in the database. Accepts a riak object, created with the `:riakc_obj` module as the argument.
  """
  @spec get(String.t, String.t) :: :riakc_obj.riakc_obj
  def get(bucket, key) do
    run fn (worker)->
      :riakc_pb_socket.get worker, bucket, key
    end
  end


  @spec put(:riakc_obj.riakc_obj) :: :riakc_obj.riakc_obj
  def put(object) do
    run fn (worker)->
      :riakc_pb_socket.put worker, object
    end
  end


  @doc """
  Used to delete a key/value from a bucket in the database.

  ##Examples

    iex> RiakPool.delete("students", "PPQuKZsyHWVPSbs3rQQVWW9nyTe")
    :ok
  """
  @spec delete(String.t, String.t) :: :ok
  def delete(bucket, key) do
    run fn (worker)->
      :riakc_pb_socket.delete worker, bucket, key
    end
  end


  def list_buckets do
    run fn (worker)->
      :riakc_pb_socket.list_buckets worker
    end
  end


  @doc """
  Used to test if connection to your database is fine. Should return `:pong`.

  ##Examples

    iex> RiakPool.ping
    :pong
  """
  @spec ping() :: atom
  def ping do
    run fn (worker)->
      :riakc_pb_socket.ping worker
    end
  end

end
