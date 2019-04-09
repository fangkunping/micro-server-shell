defmodule MicroServerShell.RpcWorkerConst do
  defmacro create do

    quote do
      def at_tick_time() do
        Application.get_env(:micro_server_shell, :rpc_work).tick_time
      end
      def at_user_node() do
        Application.get_env(:micro_server_shell, :rpc_work).user_node
      end
    end
  end
end
