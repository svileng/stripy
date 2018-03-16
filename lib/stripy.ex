defmodule Stripy do
  @moduledoc """
  Stripy is a micro wrapper intended to be
  used for sending requests to Stripe's REST API. It is
  made for developers who prefer to work directly with the
  official API and provide their own abstractions on top
  if such are needed.

  Stripy takes care of setting headers, encoding the data,
  configuration settings, etc (the usual boring boilerplate);
  it also provides a `parse/1` helper function for decoding.

  Some basic examples:

      iex> Stripy.req(:get, "subscriptions")
      {:ok, %HTTPoison.Response{...}}

      iex> Stripy.req(:post, "customers", %{"email" => "a@b.c", "metadata[user_id]" => 1})
      {:ok, %HTTPoison.Response{...}}

  You are expected to build your business logic on top
  of Stripy and abstract things such as Subscriptions
  and Customers; if that's not your cup of tea,
  check out "stripity_stripe" or "stripe_elixir" on Hex.
  """

  @doc "Constructs HTTPoison header list with auth."
  def headers(%{secret_key: sk, version: v}) do
    [{"Authorization", "Bearer #{sk}"},
     {"Content-Type", "application/x-www-form-urlencoded"},
     {"Stripe-Version", v}]
  end

  @doc "Constructs url with query params from given data."
  def url(api_url, resource, data) do
    api_url <> resource <> "?" <> URI.encode_query(data)
  end

  @doc """
  Makes request to the Stripe API.

  Will return an HTTPoison standard response; see `parse/1`
  for decoding the response body.

  ## Examples
      iex> Stripy.req(:get, "subscriptions")
      {:ok, %HTTPoison.Response{...}}

      iex> Stripy.req(:post, "customers", %{"email" => "a@b.c", "metadata[user_id]" => 1})
      {:ok, %HTTPoison.Response{...}}
  """
  def req(action, resource, data \\ %{}) when action in [:get, :post, :delete] do
    if Application.get_env(:stripy, :testing, false) do
      mock_server = Application.get_env(:stripy, :mock_server, Stripy.MockServer)
      mock_server.request(action, resource, data)
    else
      header_params = %{
        secret_key: Application.fetch_env!(:stripy, :secret_key),
        version: Application.get_env(:stripy, :version, "2017-06-05")
      }
      api_url = Application.get_env(:stripy, :endpoint, "https://api.stripe.com/v1/")
      options = Application.get_env(:stripy, :httpoison, [])

      url = url(api_url, resource, data)
      HTTPoison.request(action, url, "", headers(header_params), options)
    end
  end

  @doc "Parses an HTTPoison response from a Stripe API call."
  def parse({:ok, %{status_code: 200, body: body}}) do
    {:ok, Poison.decode!(body)}
  end
  def parse({:ok, %{body: body}}) do
    error = Poison.decode!(body) |> Map.fetch!("error")
    {:error, error}
  end
  def parse({:error, error}), do: {:error, error}
end
