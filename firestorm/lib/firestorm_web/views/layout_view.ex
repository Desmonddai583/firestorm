defmodule FirestormWeb.LayoutView do
  use FirestormWeb, :view

  def page_class(conn) do
    [
      "page",
      controller_simple_name(conn),
      Phoenix.Controller.action_name(conn)
    ] |> Enum.join("-")
  end

  defp controller_simple_name(conn) do
    conn
    |> Phoenix.Controller.controller_module()
    |> Module.split()
    # Remove "Firestorm.Web" bit
    |> Enum.drop(1)
    |> hd()
    # Remove the "Controller" bit
    |> String.replace_trailing("Controller", "")
    |> String.downcase()
  end

  def js_script_tag do
    if Mix.env == :prod do
      # In production we'll just reference the file
      "<script src=\"/js/app.js\"></script>"
    else
      # In development mode we'll load it from our webpack dev server
      "<script src=\"http://localhost:8080/js/app.js\"></script>"
    end
  end

  # Ditto for the css
  def css_link_tag do
    if Mix.env == :prod do
      "<link rel=\"stylesheet\" type=\"text/css\" href=\"/css/app.css\" />"
    else
      "<link rel=\"stylesheet\" type=\"text/css\" href=\"http://localhost:8080/css/app.css\" />"
    end
  end
end
