defmodule MicroServerShell.ScriptController do
  use MicroServerShell.Web, :controller
  alias MicroServerShell.Remoting

  def index(conn, _params) do
    # raise MicroServerShell.RpcError, conn: conn
    user = conn.assigns[:current_user]
    scripts = Remoting.Script.get_scripts(user.access_party.vip_type, user.access_party.id)
    render(conn, "index.html", scripts: scripts)
  end

  def show(conn, %{"id" => script_id}) do
    user = conn.assigns[:current_user]

    script =
      Remoting.Script.get_script(
        user.access_party.vip_type,
        user.access_party.id,
        script_id |> String.to_integer()
      )

    render(conn, "show.html", script: script)
  end

  def edit(conn, %{"id" => script_id} = params) do
    user = conn.assigns[:current_user]

    script =
      Remoting.Script.get_script(
        user.access_party.vip_type,
        user.access_party.id,
        script_id |> String.to_integer()
      )

    {conn, editor} =
      case params |> Map.get("editor") do
        nil ->
          case get_session(conn, :editor) do
            nil ->
              {put_session(conn, :editor, "simple"), "simple"}

            v ->
              {conn, v}
          end

        editor ->
          {put_session(conn, :editor, editor), editor}
      end

    scripts =
      Remoting.Script.get_scripts(user.access_party.vip_type, user.access_party.id)
      |> Enum.sort(fn s1, s2 ->
        s1.name > s2.name
      end)

    render(conn, "edit_#{editor}.html",
      script: script,
      token: get_csrf_token(),
      scripts: scripts
    )
  end

  def update(conn, params) do
    user = conn.assigns[:current_user]
    access_partys_id = user.access_party.id

    {:ok, _script} =
      Remoting.Script.update_script(user.access_party.vip_type, access_partys_id, params)

    if params["samepage"] == "1" do
      conn
      |> redirect(to: script_path(conn, :edit) <> "?id=#{params["id"]}")
    else
      conn
      |> redirect(to: script_path(conn, :index))
    end
  end

  def new(conn, _params) do
    render(conn, "new.html",
      script: %{
        id: -1,
        name: "",
        note: "",
        content: ""
      },
      token: get_csrf_token()
    )
  end

  def create(conn, params) do
    user = conn.assigns[:current_user]
    access_partys_id = user.access_party.id

    case Remoting.Script.create_script(user.access_party.vip_type, access_partys_id, params) do
      :ok ->
        conn
        |> redirect(to: script_path(conn, :index))

      {:error, msg} ->
        conn
        |> put_flash(:error, msg)
        |> redirect(to: script_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => script_id}) do
    user = conn.assigns[:current_user]
    access_partys_id = user.access_party.id

    {:ok, _} =
      Remoting.Script.delete_script(
        user.access_party.vip_type,
        access_partys_id,
        script_id |> String.to_integer()
      )

    conn
    |> redirect(to: script_path(conn, :index))
  end
end
