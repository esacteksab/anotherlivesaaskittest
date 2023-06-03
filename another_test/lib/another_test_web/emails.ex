defmodule AnotherTestWeb.EmailHTML do
  @moduledoc """
  This viewmodule is responsible for rendering the emails and the layouts.
  Can be used in the notifier by adding:

      AnotherTest.Mailer

  Or:

      import Swoosh.Email
      import AnotherTest.Mailer, only: [base_email: 0, premail: 1, render_body: 3]

  """
  use AnotherTestWeb, :html

  embed_templates "emails/*.html"
  embed_templates "emails/*.text", suffix: "_text"
end
