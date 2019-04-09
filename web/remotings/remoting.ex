defmodule MicroServerShell.Remoting do
  @spec call(atom, atom, atom) :: any
  def call(vip_type, module, fun) do
    call(nil, vip_type, module, fun, [])
  end

  @spec call(atom, atom, atom, list) :: any
  def call(vip_type, module, fun, args) when is_atom(vip_type) do
    call(nil, vip_type, module, fun, args)
  end

  @spec call(Plug.Conn, atom, atom, atom) :: any
  def call(conn, vip_type, module, fun) do
    call(conn, vip_type, module, fun, [])
  end

  @doc """
  调用远程模块对应的函数

  ## 例子

      iex> MicroServerShell.Remoting.call(nil, :vip0, String, :to_integer, ["12345"])
      iex> MicroServerShell.Remoting.call(:vip0, String, :to_integer, ["12345"])
      iex> MicroServerShell.Remoting.call(:vip0, :erlang, :now)
  """
  @spec call(Plug.Conn, atom, atom, atom, list) :: any
  def call(conn, vip_type, module, fun, args) do
    case MicroServerShell.RpcWorker.get_node(vip_type) do
      nil ->
        raise MicroServerShell.RpcError, message: "node not exist", conn: conn

      node ->
        case :rpc.call(node, module, fun, args, 10000) do
          {:badrpc, reason} ->
            reason |> IO.inspect()
            raise MicroServerShell.RpcError, message: "rpc run error", conn: conn

          res ->
            res
        end
    end
  end
end
