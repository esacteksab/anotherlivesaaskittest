defmodule AnotherTest.OneOffs.RunOneOffsWorker do
  @moduledoc """
  The worker is called when application boots to run
  one off tasks.
  If you have a very long running task, you can increase the
  unique period.
  """
  use Oban.Worker, unique: [period: 120]

  alias AnotherTest.OneOffs

  @impl Oban.Worker
  def perform(_job) do
    OneOffs.execute()
    :ok
  end
end
