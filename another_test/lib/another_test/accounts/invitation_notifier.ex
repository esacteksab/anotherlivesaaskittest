defmodule AnotherTest.Accounts.InvitationNotifier do
  @moduledoc """
  This module contains notifications aimed towards the user.
  """
  import Swoosh.Email

  @doc """
  This email is used from the Teams module to invite a new user to an account
  """
  def invite_user_email(%{email: email, url: url}) do
    new()
    |> from({"AnotherTest", "contact@example.com"})
    |> subject("Invited to join")
    |> to(email)
    |> text_body("""
    You are invited to join the team

    Please use the following url to join:

    #{url}

    You can disregard this email if you think it was sent to you by mistake.
    """)
  end
end
