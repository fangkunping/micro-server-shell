defmodule MicroServerShell.Remoting.AccessParty do
  alias MicroServerShell.Remoting

  @doc """
  通过appid 获取AccessParty
  """
  @spec get_access_party(String.t()) :: access_party :: map | nil
  def get_access_party(app_id) do
    Remoting.call(:user, MicroServer.Remoting.AccessParty, :get_access_party, [app_id])
  end
end
