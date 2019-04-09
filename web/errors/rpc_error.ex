defmodule MicroServerShell.RpcError do
  @moduledoc """
  Rpc调用出错时,调用
  """
  defexception plug_status: 441, message: "Rpc Error", conn: nil, code: -1

  def exception(opts) do
    conn = Keyword.get(opts, :conn, nil)
    message = Keyword.get(opts, :message, "Rpc Error")
    code = Keyword.get(opts, :code, -1)

    %MicroServerShell.RpcError{message: message, code: code, conn: conn}
  end
end

defimpl Plug.Exception, for: MicroServerShell.RpcError do
  def status(_exception), do: 441
end
