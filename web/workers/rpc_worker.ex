defmodule MicroServerShell.RpcWorker do
  @moduledoc """
  ## 该模块用途

    - 每隔一段时间进行节点vip设置
    - 获取节点
  """

  use GenServer
  require Kunerauqs.GenRamFunction

  Kunerauqs.GenRamFunction.gen_def(
    write_concurrency: true,
    read_concurrency: true
  )

  require MicroServerShell.RpcWorkerConst
  MicroServerShell.RpcWorkerConst.create()

  def init_self() do
    init_ram()
  end

  def start_link(arg \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, arg, opts)
  end

  def times_up(pid) do
    pid |> GenServer.cast({:times_up})
  end

  def init(_) do
    # setup_timer(at_tick_time())
    self() |> times_up()
    {:ok, nil}
  end

  @doc """
  定时时间到
  """
  def handle_cast({:times_up}, state) do
    # 启动tick 定时
    set_nodes()
    setup_timer(at_tick_time())
    {:noreply, state}
  end

  @doc """
  启动定时器
  """
  @spec setup_timer(integer) :: any
  def setup_timer(callback_time) do
    :timer.apply_after(callback_time, __MODULE__, :times_up, [self()])
  end

  @doc """
  nodes节点配置

    - 获取所有的node
    - 解析node, 找出vip开头的数据, node的数据应该表现为 vip0@127.0.0.1, vip1@127.0.0.1, vip1_1@127.0.0.1等
    - 将数据加入ram
    - 删除ram中不存在的vip 类型
  """
  def set_nodes() do
    :erlang.nodes()
    |> Enum.reduce(%{}, fn node_name, acc ->
      node_name
      |> :erlang.atom_to_binary(:latin1)
      |> String.split("@")
      |> List.first()
      |> (fn vip_str ->
            vip_atom = vip_str |> String.split("_") |> List.first() |> String.to_atom()

            case acc |> Map.has_key?(vip_atom) do
              true -> acc |> Map.put(vip_atom, [node_name | acc[vip_atom]])
              false -> acc |> Map.put(vip_atom, [node_name])
            end
          end).()
    end)
    |> Map.to_list()
    |> Enum.map(fn {k, v} ->
      write(k, v)
      k
    end)
    |> (fn keys ->
          # 删除ram中不存在的vip 类型
          read_all()
          |> Enum.each(fn {k, _} ->
            if k not in keys do
              delete(k)
            end
          end)
        end).()

    # read_all() |> IO.inspect()
  end

  @doc """
  获得节点
  """
  def get_node(:user) do
    get_node(at_user_node())
  end

  def get_node(vip_type) do
    case read(vip_type) do
      nil ->
        nil

      vip_nodes ->
        vip_nodes |> Enum.shuffle() |> List.first()
    end
  end
end
