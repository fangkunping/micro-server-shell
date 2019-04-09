defmodule MicroServerShell.ConsoleController do
  use MicroServerShell.Web, :controller

  def get_token(conn, %{"username" => username, "password" => password}) do
    case MicroServerShell.Remoting.User.get_user(conn, username, password) do
      nil -> response(conn, "用户名密码错误")
      user -> response(conn, %{token: MicroServerShell.ConsoleTokenWorker.gen_token(user)})
    end
  end

  @doc """
  更新脚本
  """
  def upload_script(
        conn,
        %{"token" => token, "id" => script_id, "content" => script_content} = params
      ) do
    case MicroServerShell.ConsoleTokenWorker.get_user(token) do
      nil ->
        response(conn, "token过期")

      user ->
        update_data =
          [
            fn
              %{"name" => name}, acc -> acc |> Map.put("name", name)
              _, acc -> acc
            end,
            fn
              %{"note" => note}, acc -> acc |> Map.put("note", note)
              _, acc -> acc
            end
          ]
          |> Enum.reduce(
            %{
              "id" => script_id,
              "content" => script_content
            },
            fn f, acc ->
              f.(params, acc)
            end
          )

        MicroServerShell.Remoting.Script.update_script(
          user.access_party.vip_type,
          user.access_party.id,
          update_data
        )

        response(conn, :ok)
    end
  end

  @doc """
  如果脚本存在更新,否则创建
  """
  def create_or_update_script(
        conn,
        %{"token" => token, "content" => script_content, "name" => name, "note" => note}
      ) do
    case MicroServerShell.ConsoleTokenWorker.get_user(token) do
      nil ->
        response(conn, "token过期")

      user ->
        update_data = %{
          "content" => script_content,
          "name" => name,
          "note" => note
        }

        scripts =
          MicroServerShell.Remoting.Script.get_script_by_name(
            user.access_party.vip_type,
            user.access_party.id,
            name
          )

        rt =
          case scripts do
            # 不存在记录, 则新建记录
            [] ->
              MicroServerShell.Remoting.Script.create_script(
                user.access_party.vip_type,
                user.access_party.id,
                update_data
              )

            # 存在记录,则更新;
            [script | _] ->
              MicroServerShell.Remoting.Script.update_script(
                user.access_party.vip_type,
                user.access_party.id,
                update_data |> Map.put("id", script.id)
              )
          end

        case rt do
          {:ok, script} ->
            response(conn, %{script_id: script.id})

          {:error, err} when is_binary(err) ->
            response(conn, "其它错误", err)

          _ ->
            response(conn, "其它错误", "Database error")
        end
    end
  end

  @doc """
  删除不符合id的脚本
  """
  def delete_script_not_in(conn, %{"token" => token, "script_ids" => script_ids}) do
    case MicroServerShell.ConsoleTokenWorker.get_user(token) do
      nil ->
        response(conn, "token过期")

      user ->
        script_ids =
          script_ids |> String.split(",") |> Enum.map(fn e -> e |> String.to_integer() end)

        MicroServerShell.Remoting.Script.get_scripts(
          user.access_party.vip_type,
          user.access_party.id
        )
        |> Enum.each(fn script ->
          if script.id not in script_ids && script.access_partys_id == user.access_party.id do
            MicroServerShell.Remoting.Script.delete_script(
              user.access_party.vip_type,
              user.access_party.id,
              script.id
            )
          end
        end)

        response(conn, :ok)
    end
  end

  @doc """
  更新 server 信息
  """
  def update_server(conn, %{
        "token" => token,
        "id" => id,
        "script_sequence" => script_sequence,
        "name" => name,
        "note" => note
      }) do
    case MicroServerShell.ConsoleTokenWorker.get_user(token) do
      nil ->
        response(conn, "token过期")

      user ->
        case MicroServerShell.Remoting.Server.update_server(user.access_party.vip_type, user.access_party.id, %{
               "id" => id,
               "script_sequence" => script_sequence,
               "name" => name,
               "note" => note
             }) do
          {:ok, _} ->
            response(conn, :ok)

          {:error, err} when is_binary(err) ->
            response(conn, "其它错误", err)

          _ ->
            response(conn, "其它错误", "Database error")
        end
    end
  end

  defp response(conn, "用户名密码错误") do
    conn
    |> json(%{
      code: 4001
    })
  end

  defp response(conn, "token过期") do
    conn
    |> json(%{
      code: 4002
    })
  end

  defp response(conn, :ok) do
    conn
    |> json(%{
      code: 0
    })
  end

  defp response(conn, data) do
    conn
    |> json(%{
      code: 0,
      data: data
    })
  end

  defp response(conn, "其它错误", err_string) do
    conn
    |> json(%{
      code: 4000,
      error: err_string
    })
  end
end
