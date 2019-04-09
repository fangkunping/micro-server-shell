defmodule MicroServerShell.UserSocket do
  use Phoenix.Socket

  require MicroServerShell.WebsocketConst
  MicroServerShell.WebsocketConst.create()

  alias MicroServerShell.Remoting
  @continue 1
  @fail 2
  @finish 3

  ## Channels
  channel("ant:*", MicroServerShell.AntChannel)

  ## Transports
  transport(:websocket, Phoenix.Transports.WebSocket)
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(
        %{"server_token" => <<app_id::bytes-size(32)>> <> <<_server_type::bytes-size(1)>> <> server_id} = params,
        socket
      ) do
    server_id = server_id |> String.to_integer()

    f = fn
      # 以下根据不同条件写逻辑, 第一个肯定是 _
      {_, lstate}, "AccessParty 是否存在" ->
        case Remoting.AccessParty.get_access_party(app_id) do
          nil ->
            {@fail, %{lstate | result: :error}}

          access_party ->
            vip_type = "vip#{access_party.vip}" |> String.to_atom()

            case MicroServerShell.WebSocketUtility.socket_connect(
                   app_id,
                   vip_type,
                   self()
                 ) do
              true ->
                # 将登录信息发送到 lua 服务端
                case MicroServerShell.Remoting.Server.websocket_send_to_lua_socket_connect(
                       vip_type,
                       server_id,
                       params
                     ) do
                  [true] ->
                    new_socket =
                      socket
                      |> assign(:app_id, app_id)
                      |> assign(:vip_type, vip_type)

                    {@finish, %{lstate | result: {:ok, new_socket}}}

                  _ ->
                    {@fail, %{lstate | result: :error}}
                end

              false ->
                {@fail, %{lstate | result: :error}}
            end
        end

      # 以下两个必须存在
      {_, %{result: result}}, :return ->
        result

      lstate_full, _ ->
        lstate_full
    end

    {@continue,
     %{
       result: nil
     }}
    |> f.("AccessParty 是否存在")
    |> f.(:return)
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     MicroServerShell.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  # def id(socket), do: "users_socket:#{socket.assigns.uuid}"
  def id(_socket), do: nil
end
