defmodule MicroServerShell.Locale do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    # case conn.params["locale"] || get_session(conn, :locale) do
    #  nil     -> conn
    #  locale  ->
    #    Gettext.put_locale(MyApp.Gettext, locale)
    #    conn |> put_session(:locale, locale)
    # end
    locale = "zh"
    Gettext.put_locale(MicroServerShell.Gettext, locale)
    conn |> put_session(:locale, locale)
  end

end
