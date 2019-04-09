defmodule MicroServerShell.WebSocketWorker do
  use GenServer
  # ets ram
  require Kunerauqs.GenRamFunction

  Kunerauqs.GenRamFunction.gen_def(
    write_concurrency: false,
    read_concurrency: false
  )

  def init_self() do
    init_ram()
  end

  @moduledoc """
  监控socket 的 transport_pid
  """
  def start_link(arg \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, arg, [{:name, __MODULE__} | opts])
  end

  def init(_) do
    {:ok, nil}
  end

  @doc """
  生成uuid
  """
  def handle_call({:gen_uuid}, _from_pid, state) do
    old_uuid = read!(:uuid, 0)
    uuid = old_uuid + 1
    write(:uuid, uuid)
    {:reply, uuid, state}
  end

  @doc """
  socket链接上
  """
  def handle_call({:socket_connect, transport_pid}, _from_pid, state) do
    Process.monitor(transport_pid)
    {:reply, :ok, state}
  end

  def handle_call(_, _from_pid, state) do
    {:reply, :ok, state}
  end

  @doc """
  socket断开
  """
  def handle_info({:DOWN, _ref, :process, transport_pid, _reason}, state) do
    MicroServerShell.WebSocketUtility.socket_disconnect(transport_pid)
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
