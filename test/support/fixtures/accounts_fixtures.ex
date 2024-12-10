defmodule PollingApp.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PollingApp.Accounts` context.
  """

  def unique_username, do: "user#{System.unique_integer()}_name"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      username: unique_username()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> PollingApp.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
