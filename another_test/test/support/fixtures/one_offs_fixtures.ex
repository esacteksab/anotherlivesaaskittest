defmodule AnotherTest.OneOffsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AnotherTest.OneOffs` context.
  """


  alias AnotherTest.OneOffs

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        module: "some module"
      })

    {:ok, task} = OneOffs.create_task(attrs)

    task
  end
end
