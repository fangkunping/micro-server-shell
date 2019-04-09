defmodule MicroServerShell.Remoting.Server do
  alias MicroServerShell.Remoting

  @doc """
  获取服务器列表
  """
  @spec get_servers(atom, integer) :: list
  def get_servers(vip_type, access_party_id) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :get_servers, [access_party_id])
  end

  @doc """
  创建服务器
  """
  @spec create_server(atom, integer) :: :ok | {:error, String.t()}
  def create_server(vip_type, access_party_id) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :create_server, [access_party_id])
  end

  @doc """
  删除服务器
  """
  @spec delete_server(atom, integer, integer) :: {:ok, any} | {:error, any}
  def delete_server(vip_type, access_party_id, server_id) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :delete_server, [
      access_party_id,
      server_id
    ])
  end

  @doc """
  通过id获取Server内容
  """
  @spec get_server(atom, integer, integer) :: map | nil
  def get_server(vip_type, access_party_id, server_id) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :get_server, [access_party_id, server_id])
  end

  @doc """
  更新服务器
  """
  @spec update_server(atom, integer, map) :: {:ok, any} | {:error, any}
  def update_server(vip_type, access_party_id, server_params) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :update_server, [
      access_party_id,
      server_params
    ])
  end

  @doc """
  启动服务器
  """
  @spec start_server(atom, integer, integer) :: any
  def start_server(vip_type, access_party_id, server_id) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :start_server, [
      access_party_id,
      server_id
    ])
  end

  @doc """
  停止服务器
  """
  @spec stop_server(atom, integer, integer) :: any
  def stop_server(vip_type, access_party_id, server_id) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :stop_server, [
      access_party_id,
      server_id
    ])
  end

  @doc """
  热更新服务器
  """
  @spec hot_update_server(atom, integer, integer) :: any
  def hot_update_server(vip_type, access_party_id, server_id) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :hot_update_server, [
      access_party_id,
      server_id
    ])
  end

  @doc """
  服务器是否启动
  """
  @spec server_exist?(atom, integer) :: boolean
  def server_exist?(vip_type, server_id) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :server_exist?, [
      server_id
    ])
  end

  @doc """
  向服务器的lua端发送 websocket信息
  """
  @spec websocket_send_to_lua_websocket_message(atom, integer, term) :: :ok
  def websocket_send_to_lua_websocket_message(vip_type, server_id, message) do
    Remoting.call(
      vip_type,
      MicroServer.Remoting.Server,
      :websocket_send_to_lua_websocket_message,
      [
        server_id,
        self(),
        message
      ]
    )
  end

  @doc """
  向服务器的lua端发送http信息
  """
  @spec websocket_send_to_lua_http_message(atom, integer, term) :: :ok
  def websocket_send_to_lua_http_message(vip_type, server_id, message) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :websocket_send_to_lua_http_message, [
      server_id,
      self(),
      message
    ])
  end

  @doc """
  向服务器的lua端发送topic链接信息
  """
  @spec websocket_send_to_lua_topic_join(atom, integer, term) :: :ok
  def websocket_send_to_lua_topic_join(vip_type, server_id, message) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :websocket_send_to_lua_topic_join, [
      server_id,
      self(),
      message
    ])
  end

  @doc """
  向服务器的lua端发送topic断开信息
  """
  @spec websocket_send_to_lua_topic_leave(atom, integer) :: :ok
  def websocket_send_to_lua_topic_leave(vip_type, server_id) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :websocket_send_to_lua_topic_leave, [
      server_id,
      self()
    ])
  end

  @doc """
  向服务器的lua端发送socket链接信息
  """
  @spec websocket_send_to_lua_socket_connect(atom, integer, term) :: :ok
  def websocket_send_to_lua_socket_connect(vip_type, server_id, message) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :websocket_send_to_lua_socket_connect, [
      server_id,
      self(),
      message
    ])
  end

  @doc """
  向服务器的lua端发送socket断开信息
  """
  @spec websocket_send_to_lua_socket_disconnect(atom, integer) :: :ok
  def websocket_send_to_lua_socket_disconnect(vip_type, server_id) do
    Remoting.call(
      vip_type,
      MicroServer.Remoting.Server,
      :websocket_send_to_lua_socket_disconnect,
      [
        server_id,
        self()
      ]
    )
  end

  @doc """
  获取服务器的log
  """
  @spec get_log(atom, integer, integer) :: list
  def get_log(vip_type, access_party_id, server_id) do
    Remoting.call(vip_type, MicroServer.Remoting.Server, :get_log, [access_party_id, server_id])
  end
end
