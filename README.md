# RiakPool

Provides pooled Riak connections for Elixir. Re-connects automatically upon disconnection.

Can also be used in Erlang. Based on Basho's [Riak erlang client](https://github.com/basho/riak-erlang-client)

## Install

* To use this in your Elixir project, add it to your dependency list in `mix.exs`

  ```elixir
  defp deps do
    [
      {:riak_pool, github: "HashNuke/riak-pool"}
    ]
  end
  ```

* Run `mix deps.get`

## Starting RiakPool

There are two ways to start RiakPool

#### Manually

* `RiakPool.start_link(address, port)`

  ```elixir
  RiakPool.start_link '127.0.0.1', 8087
  ```

* `RiakPool.start_link(address, port, size_options)`

  ```elixir
  RiakPool.start_link '127.0.0.1', 8087, [size: 6, max_overflow: 12]
  ```

Default value for pool `size` is 5 and `max_overflow` is 10.

#### Add it to your supervision tree

Here's an example. Notice the `init` function.

```elixir
defmodule YourApp.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      # We are connecting to localhost, on port 8087.
      # You can also pass a third argument for size options
      worker(RiakPool, ['127.0.0.1', 8087])
    ]
    supervise children, strategy: :one_for_one
  end
end
```


## Usage

The library provides the following functions.

#### Testing Riak connection

    RiakPool.ping

Used to test if connection to your database is fine. Should return `:pong`.

    iex(1)> RiakPool.ping
    :pong


#### Put objects

    RiakPool.put(riakc_obj)

Used to create or update values in the database. Accepts a riak object, created with the `:riakc_obj` module as the argument. Refer to this [blog post](http://akash.im/2013/09/30/using-riak-with-elixir.html) on how to use the `:riakc_obj` module to encapsulate your data.


#### Get objects

    RiakPool.get(bucket, key)

Used to get the value stored for a key from in a bucket. It accepts a bucket name and the key.


#### Delete

    RiakPool.delete(bucket, key)

Used to delete a key/value from a bucket in the database. It accepts a bucket name and the key to delete.


#### Running your own stuff

    RiakPool.run(fun)

Pass a function that accepts a worker pid as the argument. It'll run the function for you.

Use this function, to perform other tasks, that this library doesn't provide helper functions for.  You can then use the worker pid with the `:riakc_pb_socket` module to connect to Riak and do something on your own.

Here's an example that lists keys in the "students" bucket:

```elixir
RiakPool.run fn(worker)->
  :riakc_pb_socket.list_keys worker, "students"
end
```

## Credits

[Akash Manohar J](http://github.com/HashNuke) wrote this.

RiakPool is available in the public domain. Or optionally under the [MIT License](https://github.com/HashNuke/riak_pool/blob/master/LICENSE).

If you use it somewhere, send me an email to tell me about it - that'll make me extremely happy.
