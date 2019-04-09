defmodule MicroServerShell.Router do
  use MicroServerShell.Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
    plug(MicroServerShell.Auth, nil)
    plug(MicroServerShell.Locale)
  end

  pipeline :csrf do
    plug(:protect_from_forgery)
  end

  pipeline :session_layout do
    plug(:put_layout, {MicroServerShell.LayoutView, :session})
  end

  pipeline :backend_layout do
    plug(:put_layout, {MicroServerShell.LayoutView, :backend})
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:allow_jsonp)
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
    plug(MicroServerShell.Auth, nil)
    plug(MicroServerShell.Locale)
  end

  pipeline :ant_api do
    plug(:accepts, ["json"])
    plug(:allow_jsonp)
  end

  scope "/", MicroServerShell do
    pipe_through([:browser, :csrf, :session_layout])

    get("/", PageController, :index)
    resources("/sessions", SessionController, only: [:delete])
    post("/signin_process", SessionController, :user_login)
    get("/signin", SessionController, :user_new)
  end

  scope "/", MicroServerShell do
    pipe_through([:browser, :csrf, :backend_layout, :authenticate])
    # == Script ==
    get("/script", ScriptController, :index)
    get("/script/show", ScriptController, :show)
    get("/script/edit", ScriptController, :edit)
    post("/script/update", ScriptController, :update)
    get("/script/new", ScriptController, :new)
    post("/script/create", ScriptController, :create)
    delete("/script/delete", ScriptController, :delete)
    # == Server ==
    get("/server", ServerController, :index)
    get("/server/show", ServerController, :show)
    get("/server/new", ServerController, :new)
    get("/server/edit", ServerController, :edit)
    post("/server/update", ServerController, :update)
    delete("/server/delete", ServerController, :delete)
    get("/server/start", ServerController, :start)
    get("/server/stop", ServerController, :stop)
    get("/server/test", ServerController, :test)
    # == Doc ==
    get("/doc", DocController, :index)
  end

  scope "/api", MicroServerShell do
    pipe_through([:api, :csrf, :authenticate])
    # == Server ==
    post("/server/test", ServerController, :api_test)
    post("/server/start", ServerController, :api_start)
    post("/server/stop", ServerController, :api_stop)
    post("/server/hot_update", ServerController, :api_hot_update)
    # get("/ant/:server_token", ServerController, :api_ant)
    # post("/ant/:server_token", ServerController, :api_ant)
  end

  scope "/api", MicroServerShell do
    pipe_through([:ant_api])
    # == Server ==
    # get("/ant/jsonp/:server_token", ServerController, :api_ant_jsonp)
    # post("/ant/jsonp/:server_token", ServerController, :api_ant_jsonp)

    # get("/ant/:server_token", ServerController, :api_ant)
    # post("/ant/:server_token", ServerController, :api_ant)

    # json, jsonp 结果返回
    get("/ant/json/:server_token", ServerController, :api_ant_json)
    post("/ant/json/:server_token", ServerController, :api_ant_json)

    # html 结果返回
    get("/ant/html/:server_token", ServerController, :api_ant_html)
    post("/ant/html/:server_token", ServerController, :api_ant_html)

    # console
    get("/ant/console/get_token", ConsoleController, :get_token)
    post("/ant/console/upload_script", ConsoleController, :upload_script)
    post("/ant/console/create_or_update_script", ConsoleController, :create_or_update_script)
    post("/ant/console/delete_script_not_in", ConsoleController, :delete_script_not_in)
    post("/ant/console/update_server", ConsoleController, :update_server)

  end

  # Other scopes may use custom stacks.
  # scope "/api", MicroServerShell do
  #   pipe_through :api
  # end
end
