defmodule MicroServerShell.HttpConst do
  defmacro create do
    quote do
      @ok 0
      @no_such_appid 1
      @script_error 2
      @server_down 3
      @time_out 4
      @unknow_error 5

      @internal_server_error 500
      @page_not_found 400
      @rpc_error 441

    end
  end
end
