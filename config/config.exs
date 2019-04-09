# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :micro_server_shell, MicroServerShell.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "C72x7QvvoWnulpDD79EUcpkihugutlvdqzWjV28zQ/gPAUI4UTdXVDNcuhkQrjnS",
  render_errors: [view: MicroServerShell.ErrorView, format: "json", accepts: ~w(html json)],
  pubsub: [name: MicroServerShell.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :micro_server_shell,
  rpc_work: %{
    tick_time: 5000,
    user_node: :vip80001
  },
  console_token_work: %{
    # 删除过期token检查时间
    tick_time: 1000, #60000,
    # token 10(10*60*1000) 分钟过期
    exp_time_step: 10 #600_000
  },
  websocket_url: "ws://localhost:4000/socket",
  http_url: "http://localhost:4000/api/ant/json",
  cdn_url: "http://localhost:4000"

config :plug, :statuses, %{
  441 => "Rpc Error"
}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
