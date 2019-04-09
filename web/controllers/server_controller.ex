defmodule MicroServerShell.ServerController do
  use MicroServerShell.Web, :controller
  alias MicroServerShell.Remoting

  require MicroServerShell.HttpConst
  MicroServerShell.HttpConst.create()

  require MicroServerShell.WebsocketConst
  MicroServerShell.WebsocketConst.create()

  def index(conn, _params) do
    user = conn.assigns[:current_user]
    servers = Remoting.Server.get_servers(user.access_party.vip_type, user.access_party.id)
    render(conn, "index.html", servers: servers, app_id: user.access_party.app_id)
  end

  def new(conn, _params) do
    user = conn.assigns[:current_user]

    case Remoting.Server.create_server(
           user.access_party.vip_type,
           user.access_party.id
         ) do
      :ok ->
        conn
        |> redirect(to: server_path(conn, :index))

      {:error, msg} ->
        conn
        |> put_flash(:error, msg)
        |> redirect(to: server_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => server_id}) do
    user = conn.assigns[:current_user]
    access_partys_id = user.access_party.id

    {:ok, _} =
      Remoting.Server.delete_server(
        user.access_party.vip_type,
        access_partys_id,
        server_id |> String.to_integer()
      )

    conn
    |> redirect(to: server_path(conn, :index))
  end

  def show(conn, %{"id" => server_id}) do
    user = conn.assigns[:current_user]

    server =
      Remoting.Server.get_server(
        user.access_party.vip_type,
        user.access_party.id,
        server_id |> String.to_integer()
      )

    render(conn, "show.html", server: server, app_id: user.access_party.app_id)
  end

  def edit(conn, %{"id" => server_id}) do
    user = conn.assigns[:current_user]

    server =
      Remoting.Server.get_server(
        user.access_party.vip_type,
        user.access_party.id,
        server_id |> String.to_integer()
      )

    render(conn, "edit.html", server: server, token: get_csrf_token())
  end

  def update(conn, params) do
    user = conn.assigns[:current_user]
    access_partys_id = user.access_party.id

    {:ok, _server} =
      Remoting.Server.update_server(user.access_party.vip_type, access_partys_id, params)

    conn
    |> redirect(to: server_path(conn, :index))
  end

  def start(conn, %{"id" => server_id}) do
    user = conn.assigns[:current_user]
    access_partys_id = user.access_party.id

    Remoting.Server.start_server(
      user.access_party.vip_type,
      access_partys_id,
      server_id |> String.to_integer()
    )

    conn
    |> redirect(to: server_path(conn, :index))
  end

  def stop(conn, %{"id" => server_id}) do
    user = conn.assigns[:current_user]
    access_partys_id = user.access_party.id

    Remoting.Server.stop_server(
      user.access_party.vip_type,
      access_partys_id,
      server_id |> String.to_integer()
    )

    conn
    |> redirect(to: server_path(conn, :index))
  end

  def test(conn, %{"id" => server_id}) do
    user = conn.assigns[:current_user]
    server_id = server_id |> String.to_integer()

    server =
      Remoting.Server.get_server(
        user.access_party.vip_type,
        user.access_party.id,
        server_id
      )

    render(conn, "test.html",
      server: server,
      server_id: server_id,
      websocket_url: Application.get_env(:micro_server_shell, :websocket_url),
      http_url: Application.get_env(:micro_server_shell, :http_url),
      app_id: user.access_party.app_id
    )
  end

  def api_test(conn, %{"id" => server_id}) do
    user = conn.assigns[:current_user]
    access_partys_id = user.access_party.id
    server_id = server_id |> String.to_integer()
    server_status = Remoting.Server.server_exist?(user.access_party.vip_type, server_id)
    server_log = Remoting.Server.get_log(user.access_party.vip_type, access_partys_id, server_id)

    conn
    |> json(%{
      is_server_running: server_status,
      server_log: server_log
    })
  end

  def api_start(conn, %{"id" => server_id}) do
    user = conn.assigns[:current_user]
    access_partys_id = user.access_party.id

    Remoting.Server.start_server(
      user.access_party.vip_type,
      access_partys_id,
      server_id |> String.to_integer()
    )

    conn
    |> json(%{})
  end

  def api_stop(conn, %{"id" => server_id}) do
    user = conn.assigns[:current_user]
    access_partys_id = user.access_party.id

    Remoting.Server.stop_server(
      user.access_party.vip_type,
      access_partys_id,
      server_id |> String.to_integer()
    )

    conn
    |> json(%{})
  end

  def api_hot_update(conn, %{"id" => server_id}) do
    user = conn.assigns[:current_user]
    access_partys_id = user.access_party.id

    Remoting.Server.hot_update_server(
      user.access_party.vip_type,
      access_partys_id,
      server_id |> String.to_integer()
    )

    conn
    |> json(%{})
  end

  def api_ant_html(conn, params) do
    f = fn response ->
      conn |> html(response)
    end

    api_ant(params, f)
  end

  def api_ant_json(conn, params) do
    f = fn response ->
      conn |> json(response)
    end

    api_ant(params, f)
  end

  defp api_ant(
         %{
           "server_token" =>
             <<app_id::bytes-size(32)>> <> <<server_type::bytes-size(1)>> <> server_id
         } = params,
         f
       ) do
    case Remoting.AccessParty.get_access_party(app_id) do
      nil ->
        f.(%{code: @no_such_appid})

      access_party ->
        vip_type = "vip#{access_party.vip}" |> String.to_atom()
        server_id = server_id |> String.to_integer()

        case server_type do
          @single_server ->
            response =
              case Remoting.Server.websocket_send_to_lua_http_message(
                     vip_type,
                     server_id,
                     params
                   ) do
                :call_lua_error ->
                  %{code: @script_error}

                :time_out ->
                  %{code: @time_out}

                :error ->
                  %{code: @server_down}

                res when is_list(res) ->
                  res |> List.first()

                e ->
                  e |> IO.inspect()
                  %{code: @unknow_error}
              end

            f.(response)

          _ ->
            f.("LeLlO WoRlD!")
        end
    end
  end
end
