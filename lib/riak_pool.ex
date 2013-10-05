defmodule RiakPool do
  use Supervisor.Behaviour

  def start_link(address, port, size_options) do
    :supervisor.start_link(__MODULE__, [address, port, size_options])
  end


  def start_link(address, port) do
    __MODULE__.start_link(address, port, [])
  end


  def init([address, port, size_options]) do
    default_pool_options = [
      name: {:local, :riak_pool},
      worker_module: RiakPool.RiakWorker,
      size: 5,
      max_overflow: 10
    ]

    worker_args = [address, port]

    children = [
      :poolboy.child_spec(:riak_pool,
        Dict.merge(default_pool_options, size_options),
        worker_args)
    ]

    supervise(children, strategy: :one_for_one)
  end


  def run(worker_function) do
    :poolboy.transaction :riak_pool, worker_function
  end


  def put(object) do
    __MODULE__.run fn (worker)->
      :riakc_pb_socket.put worker, object
    end
  end


  def delete(bucket, key) do
    __MODULE__.run fn (worker)->
      :riakc_pb_socket.delete worker, bucket, key
    end
  end


  def ping do
    __MODULE__.run fn (worker)->
      :riakc_pb_socket.ping worker
    end
  end
end
