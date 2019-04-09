defmodule MicroServerShell.ConsoleTokenWorker do
  require MicroServerShell.ConsoleTokenWorkerConst
  MicroServerShell.ConsoleTokenWorkerConst.create()

  def start_link(arg \\ []) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @doc """
  获得 token
  """
  @spec gen_token(map) :: String.t()
  def gen_token(user) do
    GenServer.call(__MODULE__, {:gen_token, user})
  end

  @doc """
  验证 token 是否存在
  """
  @spec valid?(String.t()) :: String.t()
  def valid?(token) do
    GenServer.call(__MODULE__, {:valid?, token})
  end

  @doc """
  获得 user
  """
  @spec get_user(String.t()) :: map | nil
  def get_user(token) do
    GenServer.call(__MODULE__, {:get_user, token})
  end

  def times_up(pid) do
    pid |> GenServer.cast({:times_up})
  end

  def init(_) do
    self() |> times_up()
    {:ok, %{}}
  end

  @doc """
  定时时间到
  """
  def handle_cast({:times_up}, state) do
    now_timestamp = Kunerauqs.CommonTools.timestamp()

    state =
      state
      |> Enum.filter(fn {_, %{exp_time: exp_time}} ->
        exp_time > now_timestamp
      end)
      |> :maps.from_list()

    # 启动tick 定时
    setup_timer(at_tick_time())
    {:noreply, state}
  end

  def handle_call({:gen_token, user}, _form, state) do
    token = Kunerauqs.CommonTools.uuid()

    {:reply, token, state |> Map.put(token, %{exp_time: gen_exp_time(), user: user})}
  end

  def handle_call({:valid?, token}, _form, state) do
    {:reply, state |> Map.has_key?(token), state}
  end

  def handle_call({:get_user, token}, _form, state) do
    case state |> Map.get(token) do
      nil ->
        {:reply, nil, state}

      %{user: user} ->
        {:reply, user, state |> Map.put(token, %{exp_time: gen_exp_time(), user: user})}
    end
  end

  @doc """
  启动定时器
  """
  @spec setup_timer(integer) :: any
  def setup_timer(callback_time) do
    :timer.apply_after(callback_time, __MODULE__, :times_up, [self()])
  end

  defp gen_exp_time() do
    Kunerauqs.CommonTools.timestamp() + at_exp_time_step()
  end
end
