defmodule MicroServerShell.WebSocketUtility do
  @moduledoc """
  Ets 保存app id 对应的websocket 及其 channel
  """

  # ets ram
  require Kunerauqs.GenRamFunction

  Kunerauqs.GenRamFunction.gen_def(
    write_concurrency: true,
    read_concurrency: true
  )

  def init_self() do
    init_ram()
  end

  # ets struct
  require MicroServerShell.WebSocketUtilityStruct
  MicroServerShell.WebSocketUtilityStruct.gen_struct_ref()

  alias MicroServerShell.WebSocketUtilityStruct, as: EtsObj

  # ets ms
  require Kunerauqs.GenEtsMs

  Kunerauqs.GenEtsMs.gen_def(
    # 需要操作的表名
    table: __MODULE__,
    # 操作的字段标识, 在下面面会用到, 该模块如果配合 ets struct宏使用, 请保持row_keys 一致, 详见下面例子
    row_keys: [:uuid, :app_id, :vip_type, :topic_id, :topic_pid, :transport_pid],
    ets_conditions: [
      [
        function_def: "find_by_topic_id(topic_id)",
        condition: "topic_id == ^topic_id",
        return: "all",
        action: :select,
        additon_fun: nil
      ],
      [
        function_def: "find_by_transport_pid(transport_pid)",
        condition: "transport_pid == ^transport_pid",
        return: "all",
        action: :select,
        additon_fun: nil
      ],
      [
        function_def: "delete_by_transport_pid(transport_pid)",
        condition: "transport_pid == ^transport_pid",
        action: :delete
      ],
      [
        function_def: "delete_by_topic_pid(topic_pid)",
        condition: "topic_pid == ^topic_pid",
        action: :delete
      ],
      [
        function_def: "delete_by_topic_id(topic_id)",
        condition: "topic_id == ^topic_id",
        action: :delete
      ]
    ]
  )

  @doc """
  socket链接
  """
  @spec socket_connect(String.t(), atom, pid) :: :ok
  def socket_connect(app_id, vip_type, transport_pid) do
    EtsObj.create(%{
      @uuid => gen_uuid(),
      @app_id => app_id,
      @vip_type => vip_type,
      @transport_pid => transport_pid
    })
    |> write()

    MicroServerShell.WebSocketWorker |> GenServer.call({:socket_connect, transport_pid})
    # todo 限制app_id的连接数
    true
  end

  @doc """
  socket断开
  """
  @spec socket_disconnect(pid) :: :ok
  def socket_disconnect(transport_pid) do
    delete_by_transport_pid(transport_pid)
  end

  @doc """
  topic join
  """
  @spec topic_join(pid, String.t(), pid) :: any
  def topic_join(transport_pid, topic_id, topic_pid) do
    find_by_transport_pid(transport_pid)
    |> List.first()
    |> EtsObj.store(%{@uuid => gen_uuid(), @topic_id => topic_id, @topic_pid => topic_pid})
    |> write()
  end

  @doc """
  topic leave
  """
  @spec topic_leave(pid) :: :ok
  def topic_leave(topic_pid) do
    delete_by_topic_pid(topic_pid)
  end

  @doc """
  删除 topic
  """
  def remove_topics(topic_id) do
    find_by_topic_id(topic_id)
    |> Enum.each(fn socket_data ->
      socket_data |> EtsObj.fetch(@topic_pid) |> Process.exit(:kill)
    end)

    delete_by_topic_id(topic_id)
  end

  @doc """
  生成uuid
  """
  @spec gen_uuid() :: integer
  def gen_uuid() do
    MicroServerShell.WebSocketWorker |> GenServer.call({:gen_uuid})
  end
end
