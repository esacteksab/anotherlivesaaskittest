defmodule AnotherTest.OneOffs do
  @moduledoc """
  This module is designed to run one off taks.
  Add the task modules in the @tasks_to_run list. Ever
  task module needs to implement execute/0
  """

  import Ecto.Query, warn: false
  alias AnotherTest.Repo
  alias AnotherTest.OneOffs.Task

  @tasks_to_run [
    # AnotherTest.OneOffs.Tasks.ExampleTask,
  ]

  def execute(opts \\ []) do
    executed_tasks = Enum.map(list_tasks(), & &1.module)
    tasks_to_run = Keyword.get(opts, :tasks, @tasks_to_run)

    Enum.each(tasks_to_run, fn module ->
      module_string = inspect(module)

      if Enum.member?(executed_tasks, module_string) == false do
        module.execute()

        create_task(%{module: module_string})
      end
    end)
  end

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks() do
    Repo.all(Task)
  end

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end
end
