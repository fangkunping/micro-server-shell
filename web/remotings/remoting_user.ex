defmodule MicroServerShell.Remoting.User do
  alias MicroServerShell.Remoting

  @doc """
  通过用户id 获取用户数据

  ## 例子

      iex> MicroServerShell.Remoting.User.get_user(1)
  """
  @spec get_user(userid :: integer) :: user :: map | nil
  def get_user(userid) do
    Remoting.call(:user, MicroServer.Remoting.User, :get_user, [userid])
  end

  @spec get_user(Plug.Conn, integer) :: user :: map | nil
  def get_user(%Plug.Conn{} = conn, userid) do
    Remoting.call(conn, :user, MicroServer.Remoting.User, :get_user, [userid])
  end

  @doc """
  通过 用户名, 密码, 获取用户数据
  """
  @spec get_user(String.t(), String.t()) :: user :: map | nil
  def get_user(username, password) do
    Remoting.call(:user, MicroServer.Remoting.User, :get_user, [username, password])
  end

  @spec get_user(Plug.Conn, String.t(), String.t()) :: user :: map | nil
  def get_user(conn, username, password) do
    Remoting.call(conn, :user, MicroServer.Remoting.User, :get_user, [username, password])
  end
end
