defmodule AnotherTest.Repo.Migrations.AddBillingTables do
  use Ecto.Migration

  def change do
    ## Users

    alter table(:users) do
      add :customer_type, :string
      add :remote_id, :string
      add :billing_email, :string
      add :card_brand, :string
      add :card_exp_month, :integer
      add :card_exp_year, :integer
      add :card_last4, :string
    end

    create unique_index(:users, [:remote_id])

    ## Products

    create table(:billing_products) do
      add :remote_id, :string, null: false
      add :name, :string
      add :description, :text
      add :local_name, :string
      add :local_description, :text
      add :active, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:billing_products, :remote_id)

    ## Plans

    create table(:billing_plans, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :remote_id, :string, null: false
      add :remote_product_id, :string, null: false
      add :name, :string
      add :local_name, :string
      add :amount, :integer
      add :currency, :string
      add :interval, :string
      add :interval_count, :integer
      add :trial_period_days, :integer
      add :usage_type, :string
      add :active, :boolean, default: false, null: false

      timestamps()
    end

    create index(:billing_plans, [:remote_product_id])
    create unique_index(:billing_plans, [:remote_id])

    ## Subscriptions

    create table(:billing_subscriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :cancel_at, :naive_datetime
      add :canceled_at, :naive_datetime
      add :current_period_end_at, :naive_datetime
      add :current_period_start, :naive_datetime
      add :status, :string
      add :remote_id, :string, null: false
      add :remote_plan_id, :string, null: false
      add :remote_customer_id, :string, null: false

      timestamps()
    end

    create index(:billing_subscriptions, [:remote_plan_id])
    create index(:billing_subscriptions, [:remote_customer_id])
    create unique_index(:billing_subscriptions, :remote_id)

    ## Invoices

    create table(:billing_invoices, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :remote_id, :string, null: false
      add :remote_customer_id, :string, null: false
      add :status, :string
      add :currency, :string
      add :invoice_pdf, :string
      add :hosted_invoice_url, :string
      add :subtotal, :integer

      timestamps()
    end

    create index(:billing_invoices, [:remote_customer_id])
    create unique_index(:billing_invoices, :remote_id)

    ## Memberships

    alter table(:account_memberships) do
      add :billing_customer, :boolean, default: false, null: false
    end

    # Only allow one billing customer per account
    # If you want to change this. Remove this line before migrations or make a migration that reverses this.
    # name of the index: account_memberships_account_id_billing_customer_index
    create unique_index(:account_memberships, [:account_id, :billing_customer],
             where: "billing_customer = true"
           )
  end
end
