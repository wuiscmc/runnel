defmodule Runnel.LayoutView do
  use Runnel.Web, :view

  # Takes the view_module's and view_template's name and parses it to
  # return a sensible name:
  # 
  # given a template index.html from the AuthView module, 
  # it parses it and returns
  # AuthIndexView
  def js_namespace(conn, view_module, view_template) do
    [view_name(conn), template_name(view_template)]
    |> Enum.reverse
    |> List.insert_at(0, "view")
    |> Enum.map(&String.capitalize/1)
    |> Enum.reverse
    |> Enum.join("")
  end

  # Takes the resource name of the view module and removes the
  # the ending *_view* string.
  # 
  # given a view_module 'auth_view', it returns 'auth'
  defp view_name(conn) do
    conn
    |> view_module
    |> Phoenix.Naming.resource_name
    |> String.replace("_view", "")
  end

  # Removes the extion from the template and reutrns
  # just the name.
  #
  # given a template 'index.html', it returns 'index'
  defp template_name(template) when is_binary(template) do
    template
    |> String.split(".")
    |> Enum.at(0)
  end
end
