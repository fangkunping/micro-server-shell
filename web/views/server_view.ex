defmodule MicroServerShell.ServerView do
  use MicroServerShell.Web, :view

  def get_script_sequence(server) do
    server.script_sequence
    |> Enum.map(fn script ->
      script.id
    end)
    |> Enum.join(",")
  end

  def gen_server_token(app_id, server_id) do
    #server_id_str = server_id |> Integer.to_string()
    #"#{app_id}#{String.length(server_id_str)}#{server_id_str}"
    MicroServerShell.AntChannel.gen_topic_id(app_id, server_id)
  end
end
