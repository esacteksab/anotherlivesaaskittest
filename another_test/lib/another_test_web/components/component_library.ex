defmodule AnotherTestWeb.ComponentLibrary do
  defmacro __using__(_) do
    quote do
      import AnotherTestWeb.ComponentLibrary
      # Import additional component modules below
      import AnotherTestWeb.Components.Admin
      import AnotherTestWeb.Components.Cards
      import AnotherTestWeb.Components.Tables

    end
  end
  @moduledoc """
  This module is added and used in AnotherTestWeb. The idea is
  different component modules can be added and imported in the macro section above.
  """
  use Phoenix.Component

end
