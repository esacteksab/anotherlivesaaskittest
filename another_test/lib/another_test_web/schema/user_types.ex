defmodule AnotherTestWeb.Schema.UserTypes do
  @moduledoc """
  User relates GraphQL schemas
  """
  use Absinthe.Schema.Notation

  alias AnotherTestWeb.Resolvers

  @desc "A user"
  object :user do
    field :email, :string
    field :id, :id
  end

  object :get_user do
    @desc """
    Get a specific user
    """

    field :user, :user do
      arg(:id, non_null(:id))

      resolve(&Resolvers.Users.get_user/2)
    end
  end

  object :login_mutation do
    @desc """
    login with the params
    """

    field :create_session, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Resolvers.Users.login/2)
    end
  end

  @desc "session value"
  object :session do
    field(:token, :string)
    field(:user, :user)
  end
end
