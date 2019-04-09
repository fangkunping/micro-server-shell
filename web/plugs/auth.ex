defmodule MicroServerShell.Auth do
  @moduledoc """
  登录验证模块

  ## session 包括以下信息

    - user_id: 用户id
    - current_user: 当前用户数据
  """
  import Plug.Conn
  import Phoenix.Controller
  import MicroServerShell.Gettext

  alias MicroServerShell.Router.Helpers
  # 初始化，传入 Repo
  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    # 从session里面获得用户id
    case conn.assigns[:current_user] do
      nil ->
        user_id = get_session(conn, :user_id)
        # 用户id存在的情况下，从数据库读取用户的相关信息
        user = user_id && MicroServerShell.Remoting.User.get_user(conn, user_id)

        # 把信息赋值给assign，接下来可以通过 conn.assigns.current_user 访问到该信息
        conn
        |> assign(:current_user, user)

      _ ->
        conn
    end
  end

  @doc """
  登录时设置好"当前用户"
  """
  def login(conn, user) do
    conn
    |> assign(:current_user, user)
  end

  @doc """
  登录时将"当前用户" 清除
  """
  def logout(conn) do
    conn
    |> assign(:current_user, nil)
  end

  def create_session(conn, user) do
    conn
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def destroy_session(conn) do
    configure_session(conn, drop: true)
  end

  def login_by_username_and_pass(conn, username, given_pass) do
    case MicroServerShell.Remoting.User.get_user(conn, username, given_pass) do
      nil -> {:error, :not_found, conn}
      user -> {:ok, fn -> login(conn, user) end, fn conn -> create_session(conn, user) end}
    end
  end

  @doc """
  验证用户名

  如果当前用户不存在, 说明没有登录
  """
  def authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, gettext("Access must be logged in."))
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
