defmodule MicroServerShell.WebSocketUtilityStruct do
  require Kunerauqs.GenEtsStruct

  Kunerauqs.GenEtsStruct.gen_def(
    row_keys: [:uuid, :app_id, :vip_type, :topic_id, :topic_pid, :transport_pid], #定义 tuple从左到右, 每个元素 对应代表的键名
    row_default: [], # 设置键名对应的缺省值, 如果, 没有指定, 则缺省值为 nil
    store_replace_function: nil, # 替换系统内置的保存函数 f(tuple, index, value) -> new_tuple
    fetch_replace_function: nil  # 替换系统内置的读取函数 f(tuple, index) -> value
  )

  defmacro gen_struct_ref() do
    quote do
      require Kunerauqs.GenEtsStruct
      Kunerauqs.GenEtsStruct.gen_index(row_keys: [:uuid, :app_id, :vip_type, :topic_id, :topic_pid, :transport_pid]) #必须与上面的一致
      defdelegate g(v1, v2), to: MicroServerShell.WebSocketUtilityStruct, as: :fetch #这里可以自定义修改 读取 的别名
      defdelegate s(v1, v2, v3), to: MicroServerShell.WebSocketUtilityStruct, as: :store  #这里可以自定义修改 保存 的别名
    end
  end
end
