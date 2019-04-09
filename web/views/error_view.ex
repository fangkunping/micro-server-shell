defmodule MicroServerShell.ErrorView do
  use MicroServerShell.Web, :view

  require MicroServerShell.HttpConst
  MicroServerShell.HttpConst.create()

  def render("404.html", _assigns) do
    #"Page not found"
    %{code: @page_not_found}
  end

  def render("500.html", _assigns) do
    #"Internal server error"
    %{code: @internal_server_error}
  end

  def render("441.html", _assigns) do
    #"441"
    %{code: @rpc_error}
  end

  def render("441.json", _assigns) do
    %{code: @rpc_error}
  end

  def render("441.json-api", _assigns) do
    %{code: @rpc_error}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
