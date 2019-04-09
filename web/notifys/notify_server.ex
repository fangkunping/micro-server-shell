defmodule MicroServerShell.Notify.Server do
  @doc """
  远程服务器关闭
  """
  @spec server_down(integer, integer) :: any
  def server_down(app_id, server_id) do
      topic_id = MicroServerShell.AntChannel.gen_topic(app_id, server_id)
      MicroServerShell.WebSocketUtility.remove_topics(topic_id)
  end
end
