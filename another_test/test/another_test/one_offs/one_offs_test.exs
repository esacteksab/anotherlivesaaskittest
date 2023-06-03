defmodule AnotherTest.OneOffsTest do
  use AnotherTest.DataCase

  alias AnotherTest.OneOffs
  alias AnotherTest.OneOffs.Task

  import AnotherTest.OneOffsFixtures

  defmodule TestTask do
    def execute, do: send(self(), :task_executed)
  end

  describe "tasks" do
    @invalid_attrs %{module: nil}

    test "execute/0 executes the test task" do
      OneOffs.execute(tasks: [TestTask])
      assert [%Task{module: "AnotherTest.OneOffsTest.TestTask"}] = OneOffs.list_tasks()
      assert_received :task_executed
    end

    test "execute/0 does not execute the test task if its in the database" do
      task_fixture(%{module: "AnotherTest.OneOffsTest.TestTask"})

      OneOffs.execute(tasks: [TestTask])
      assert length(OneOffs.list_tasks()) == 1
      refute_received :task_executed
    end

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert OneOffs.list_tasks() == [task]
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{module: "some module"}

      assert {:ok, %Task{} = task} = OneOffs.create_task(valid_attrs)
      assert task.module == "some module"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = OneOffs.create_task(@invalid_attrs)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = OneOffs.delete_task(task)
      assert OneOffs.list_tasks() == []
    end
  end
end
