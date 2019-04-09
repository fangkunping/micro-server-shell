defmodule MicroServerShell.WebsocketConst do
  defmacro create do
    quote do
      @ant_join 1
      @ant_terminate 2

      @join_success 1
      @join_wrong_channel 2
      @server_down 3
      @join_refuse 4

      @single_server "1"
      @concurrent_server "2"
    end
  end
end
