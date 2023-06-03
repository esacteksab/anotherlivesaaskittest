defmodule AnotherTest.Campaigns.Campaign do
  @moduledoc """
  The Campaign Macro.
  """
  @type query :: Ecto.Query.t

  @callback apply_scopes(query) :: query

  defmacro __using__(opts \\ [scopes: [], steps: []]) do
    scopes = Keyword.get(opts, :scopes, [])
    steps = Keyword.get(opts, :steps, [])
    days_between = Keyword.get(opts, :days_between)
    notifier_module = Keyword.get(opts, :notifier_module)

    quote do
      @behaviour AnotherTest.Campaigns.Campaign

      import AnotherTest.Campaigns.Campaign

      @doc """
      Name of the current campaign that implements this macro.
      """
      def name do
        Macro.underscore(__MODULE__)
        |> String.split("/")
        |> List.last()
        |> String.to_atom()
      end

      def first_step, do: List.first(unquote(steps))
      def steps, do: unquote(steps)
      def days_between, do: unquote(days_between)

      def days_until_next_step(_prev_step) do
        unquote(days_between)
      end

      @doc """
      Invoke the notifier for the step passed in
      """
      def execute_step(step, user) do
        unquote(notifier_module).deliver(step, user)
      end

      def apply_scopes(query) do
        Enum.reduce(unquote(scopes), query, fn scope, current_query ->
          apply(__MODULE__, scope, [current_query])
        end)
      end
    end
  end
end
