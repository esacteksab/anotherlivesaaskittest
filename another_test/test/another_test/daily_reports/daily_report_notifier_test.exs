defmodule AnotherTest.DailyReports.DailyReportNotifierTest do
  use ExUnit.Case, async: true
  import Swoosh.TestAssertions

  alias AnotherTest.DailyReports.DailyReportNotifier

  test "deliver_notify/1" do
    metrics = [{"users", :inserted_at, 2}, {"accounts", :inserted_at, 1}]
    args = %{email: "alice@example.com", metrics: metrics}

    DailyReportNotifier.deliver_report(args)
    |> AnotherTest.Mailer.deliver()

    assert_email_sent(
      subject: "Daily Report",
      to: "alice@example.com",
      text_body: ~r/users inserted_at 2/
    )
  end
end
