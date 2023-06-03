defmodule AnotherTest.DailyReports.DailyReportNotifier do
  @moduledoc false

  import Swoosh.Email
  import AnotherTest.Mailer, only: [base_email: 0, premail: 1, render_body: 3]

  @doc """
  This email contains a daily report sent to an admin
  """
  def deliver_report(%{email: email, metrics: metrics}) do
    base_email()
    |> subject("Daily Report")
    |> to(email)
    |> render_body("daily_report.html", title: "Daily Report", metrics: metrics)
    |> premail()
  end
end
