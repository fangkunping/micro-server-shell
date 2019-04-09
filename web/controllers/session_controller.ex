defmodule MicroServerShell.SessionController do
  use MicroServerShell.Web, :controller
  alias MicroServerShell.Auth

  def user_new(conn, _) do
    render(conn, "new_user.html")
  end

  def user_login(conn, opts) do
    case createp(conn, opts) do
      {:ok, login_fn, create_session_fn} ->
        conn = login_fn.()
        # 如果非激活状态, 产生错误
        if conn.assigns.current_user && conn.assigns.current_user.is_active == false do
          conn
          |> Auth.logout()
          |> put_flash(:error, gettext("Account not activated."))
          |> render("new_user.html")
        else
          conn
          |> create_session_fn.()
          |> redirect(to: page_path(conn, :index))
        end

      {:error, conn} ->
        conn |> render("new_user.html")
    end
  end

  defp createp(conn, %{"username" => user, "password" => pass}) do
    case MicroServerShell.Auth.login_by_username_and_pass(conn, user, pass) do
      {:ok, login_fn, create_session_fn} ->
        {:ok, login_fn, create_session_fn}

      {:error, _reason, conn} ->
        {:error, conn |> put_flash(:error, gettext("Invalid username/password combination"))}
    end
  end

  def delete(conn, _) do
    conn
    |> Auth.logout()
    |> Auth.destroy_session()
    |> redirect(to: page_path(conn, :index))
  end
end
