defmodule RiakPool.RiakWorker do

  def start_link([ip, port]) do
    :riakc_pb_socket.start_link(ip, port)
  end


  def start_link([ip, port, options]) do
    :riakc_pb_socket.start_link(ip, port, options)
  end
end