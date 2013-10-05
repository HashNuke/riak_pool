defmodule RiakPool.Mixfile do
  use Mix.Project

  def project do
    [ app: :riak_pool,
      version: "0.0.1",
      elixir: "~> 0.10.3",
      deps: deps ]
  end


  def application do
    [mod: []]
  end


  defp deps do
    [
      {:poolboy, github: "devinus/poolboy", tag: "1.0.0"},
      {:riakc, github: "basho/riak-erlang-client"}
    ]
  end
end
