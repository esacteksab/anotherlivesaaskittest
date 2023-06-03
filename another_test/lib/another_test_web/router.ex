defmodule AnotherTestWeb.Router do
  use AnotherTestWeb, :router

  import AnotherTestWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AnotherTestWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug AnotherTestWeb.Context
  end

  pipeline :admin do
    plug AnotherTest.Admins.Pipeline
  end

  # Set the layout for when an admin signs in
  pipeline :admin_session_layout do
    plug :put_root_layout, {AnotherTestWeb.Layouts, :session}
  end

  pipeline :require_current_admin do
    plug AnotherTestWeb.Plugs.RequireCurrentAdmin
  end

  # Set the main layout for the admin area
  pipeline :admin_layout do
    plug :put_root_layout, {AnotherTestWeb.Layouts, :admin}
  end

  # Set the layout for when a user registers or signs in
  pipeline :session_layout do
    plug :put_root_layout, {AnotherTestWeb.Layouts, :session}
  end

  scope "/", AnotherTestWeb do
    pipe_through :browser

    get "/", PageController, :home
    # live "/pricing", PricingLive.Index, :index
    get "/return_from_stripe", StripeReturnController, :new
  end

  scope "/webhooks", AnotherTestWeb do
    pipe_through :api

    post "/stripe", StripeWebhookController, :create
  end

  scope "/", AnotherTestWeb do
    get "/sitemap.xml", SitemapController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", AnotherTestWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:another_test, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AnotherTestWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AnotherTestWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated, :session_layout]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{AnotherTestWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", AnotherTestWeb do
    pipe_through [:browser, :require_authenticated_user]

    post "/create-customer-portal-session", StripeCustomerPortalSession, :create

    live_session :require_authenticated_user,
      on_mount: [{AnotherTestWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/accounts", AccountLive.Index, :index
      live "/accounts/:account_id/members", MemberLive.Index, :index
      live "/subscriptions/new", SubscriptionLive.New, :new
      live "/billing", BillingLive.Index, :index

    end
  end

  scope "/", AnotherTestWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{AnotherTestWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/auth", AnotherTestWeb do
    pipe_through :browser

    get "/:provider", OauthCallbackController, :request
    get "/:provider/callback", OauthCallbackController, :callback
  end

  scope "/admin", AnotherTestWeb.Admin, as: :admin do
    pipe_through [:browser, :admin, :admin_session_layout]

    get "/sign_in", SessionController, :new
    post "/sign_in", SessionController, :create
    delete "/sign_out", SessionController, :delete
    get "/reset_password", ResetPasswordController, :new
    post "/reset_password", ResetPasswordController, :create
    get "/reset_password/:token", ResetPasswordController, :show
  end

  scope "/admin", AnotherTestWeb.Admin, as: :admin do
    pipe_through [:browser, :admin, :require_current_admin, :admin_layout]

      live_session :admin, on_mount: [{AnotherTestWeb.Admin.InitAssigns, :admin_layout}] do
      live "/", DashboardLive.Index, :index
      live "/settings", SettingLive.Edit, :edit

      post "/impersonate/:id", UserImpersonationController, :create

      live "/accounts", AccountLive.Index, :index
      live "/accounts/:id/edit", AccountLive.Index, :edit

      live "/accounts/:id", AccountLive.Show, :show
      live "/accounts/:id/show/edit", AccountLive.Show, :edit

      live "/users", UserLive.Index, :index
      live "/users/:id", UserLive.Show, :show

      live "/admins", AdminLive.Index, :index
      live "/admins/new", AdminLive.Index, :new
      live "/admins/:id/edit", AdminLive.Index, :edit

      live "/admins/:id", AdminLive.Show, :show
      live "/admins/:id/show/edit", AdminLive.Show, :edit

      live "/developers", DeveloperLive.Index, :index

      ## BILLING
      # live "/customers", CustomerLive.Index, :index
      # live "/customers/:id", CustomerLive.Show, :show

      # live "/products", ProductLive.Index, :index
      # live "/products/:id/edit", ProductLive.Index, :edit
      # live "/products/:id", ProductLive.Show, :show
      # live "/products/:id/show/edit", ProductLive.Show, :edit

      # live "/products/:product_id/plans", PlanLive.Index, :index
      # live "/products/:product_id/plans/:id", PlanLive.Show, :show

      live "/subscriptions", SubscriptionLive.Index, :index
      live "/subscriptions/:id", SubscriptionLive.Show, :show

      # live "/invoices", InvoiceLive.Index, :index
    end
  end

  scope "/", AnotherTestWeb do
    pipe_through [:browser, :session_layout]

    live_session :require_additional_actions,
      on_mount: [{AnotherTestWeb.UserAuth, :ensure_authenticated}] do
      live "/users/two_factor", UserTwoFactorLive, :new
    end

    get "/users/two_factor/:token", UserTwoFactorController, :new
  end

  scope "/api" do
    pipe_through :graphql

    forward "/", Absinthe.Plug, schema: AnotherTestWeb.Schema
  end

  if Application.compile_env(:another_test, :dev_routes) do
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: AnotherTestWeb.Schema
  end
end
