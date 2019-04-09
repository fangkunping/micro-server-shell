defmodule MicroServerShell.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use MicroServerShell.Web, :controller
      use MicroServerShell.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      # Define common model functionality
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      import MicroServerShell.Router.Helpers
      import MicroServerShell.Gettext
      import MicroServerShell.Auth, only: [authenticate: 2]
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import MicroServerShell.Router.Helpers
      import MicroServerShell.ErrorHelpers
      import MicroServerShell.Gettext

      def cdn_url(_conn, uri) do
        cdn_url = Application.get_env(:micro_server_shell, :cdn_url)
        cdn_url <> uri
      end
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import MicroServerShell.Auth, only: [authenticate: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import MicroServerShell.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
