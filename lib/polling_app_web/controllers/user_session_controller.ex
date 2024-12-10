defmodule PollingAppWeb.UserSessionController do
  use PollingAppWeb, :controller

  alias PollingApp.Accounts
  alias PollingAppWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"username" => username} = user_params

    if user = Accounts.get_user_by_username(username) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      case Accounts.register_user(user_params) do
        {:ok, user} ->
          conn
          |> put_flash(:info, info)
          |> UserAuth.log_in_user(user, user_params)

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Invalid username")
          |> put_flash(:username, username)
      end
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
