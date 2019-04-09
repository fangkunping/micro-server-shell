defmodule MicroServerShell.AntChannel do
  use MicroServerShell.Web, :channel
  # constant
  require MicroServerShell.WebsocketConst
  MicroServerShell.WebsocketConst.create()

  alias MicroServerShell.Remoting

  def join(
        "ant:" <> <<app_id::bytes-size(32)>> <> <<server_type::bytes-size(1)>> <> server_id =
          topic_id,
        params,
        socket
      ) do
    # {"==!!!==***===> join", socket, self()} |> IO.inspect()
    server_id = server_id |> String.to_integer()
    if socket.assigns.app_id == app_id do
      vip_type = socket.assigns[:vip_type]

      case server_type do
        @single_server ->
          case Remoting.Server.server_exist?(vip_type, server_id) do
            true ->
              new_socket =
                socket
                |> assign(:server_id, server_id)

              MicroServerShell.WebSocketUtility.topic_join(socket.transport_pid, topic_id, self())
              # 将join信息发送到 lua 服务端
              case Remoting.Server.websocket_send_to_lua_topic_join(
                     vip_type,
                     server_id,
                     params
                   ) do
                [true] ->
                  {:ok, %{reason: @join_success}, new_socket}

                _ ->
                  {:error, %{reason: @join_refuse}}
              end

            false ->
              {:error, %{reason: @server_down}}
          end

        _ ->
          {:error, %{reason: "LeLlO WoRlD!"}}
      end
    else
      {:error, %{reason: @join_wrong_channel}}
    end
  end

  # 接收到返回信息
  def handle_info({:response, data}, socket) do
    push(socket, "response", %{message: data})
    {:noreply, socket}
  end

  # 离开 topic
  def handle_info({:leave}, socket) do
    {:stop, {:shutdown, :leave}, socket}
  end

  # %{"data" => data} = params
  # 接收的客户端请求
  def handle_in("request", params, socket) do
    send_msg(socket, params)
    {:noreply, socket}
  end

  def handle_in(_, _params, socket) do
    {:noreply, socket}
  end

  # 挂掉
  def terminate(_msg, socket) do
    server_id = socket.assigns[:server_id]
    vip_type = socket.assigns[:vip_type]
    MicroServerShell.WebSocketUtility.topic_leave(self())
    Remoting.Server.websocket_send_to_lua_topic_leave(vip_type, server_id)
    {:shutdown, :closed}
  end

  # 向服务器逻辑端发送客户端信息
  defp send_msg(socket, send_data) do
    server_id = socket.assigns[:server_id]
    vip_type = socket.assigns[:vip_type]
    Remoting.Server.websocket_send_to_lua_websocket_message(vip_type, server_id, send_data)
  end

  @doc """
  生成 topic
  """
  @spec gen_topic(integer, integer) :: String.t()
  def gen_topic(app_id, server_id) do
    "ant:#{gen_topic_id(app_id, server_id)}"
  end

  @doc """
  生成 topic id
  """
  @spec gen_topic_id(integer, integer) :: String.t()
  def gen_topic_id(app_id, server_id, server_type \\ @single_server) do
    "#{app_id}#{server_type}#{server_id}"
  end
end
