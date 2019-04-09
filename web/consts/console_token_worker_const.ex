defmodule MicroServerShell.ConsoleTokenWorkerConst do
  defmacro create do

    quote do
      def at_tick_time() do
        Application.get_env(:micro_server_shell, :console_token_work).tick_time
      end
      def at_exp_time_step() do
        Application.get_env(:micro_server_shell, :console_token_work).exp_time_step
      end
    end
  end
end
