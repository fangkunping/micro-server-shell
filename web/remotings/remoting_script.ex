defmodule MicroServerShell.Remoting.Script do
  alias MicroServerShell.Remoting

  @doc """
  获取脚本
  """
  @spec get_scripts(atom, integer) :: list
  def get_scripts(vip_type, access_party_id) do
    Remoting.call(vip_type, MicroServer.Remoting.Script, :get_scripts, [access_party_id])
  end

  @doc """
  通过id获取脚本内容
  """
  @spec get_script(atom, integer, integer) :: map | nil
  def get_script(vip_type, access_party_id, script_id) do
    Remoting.call(vip_type, MicroServer.Remoting.Script, :get_script, [access_party_id, script_id])
  end

  @spec get_script_by_name(atom, integer, String.t()) :: list
  def get_script_by_name(vip_type, access_party_id, script_name) do
    Remoting.call(vip_type, MicroServer.Remoting.Script, :get_script_by_name, [
      access_party_id,
      script_name
    ])
  end

  @doc """
  更新脚本
  """
  @spec update_script(atom, integer, map) :: {:ok, any} | {:error, any}
  def update_script(vip_type, access_party_id, script_params) do
    Remoting.call(vip_type, MicroServer.Remoting.Script, :update_script, [
      access_party_id,
      script_params
    ])
  end

  @doc """
  创建新脚本
  """
  @spec create_script(atom, integer, map) :: {:ok, any} | {:error, String.t()}
  def create_script(vip_type, access_party_id, script_params) do
    Remoting.call(vip_type, MicroServer.Remoting.Script, :create_script, [
      access_party_id,
      script_params
    ])
  end

  @doc """
  删除脚本
  """
  @spec delete_script(atom, integer, integer) :: {:ok, any} | {:error, any}
  def delete_script(vip_type, access_party_id, script_id) do
    Remoting.call(vip_type, MicroServer.Remoting.Script, :delete_script, [
      access_party_id,
      script_id
    ])
  end

end
