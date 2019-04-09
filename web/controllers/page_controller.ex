defmodule MicroServerShell.PageController do
  use MicroServerShell.Web, :controller

  def index(conn, _params) do
    # raise MicroServerShell.RpcError, conn: conn
    # render(conn, "index.html")
    case conn.assigns[:current_user] do
      nil ->
        conn |> redirect(to: session_path(conn, :user_new))

      _ ->
        conn |> redirect(to: server_path(conn, :index))
    end
  end
end
