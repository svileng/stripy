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

  @doc """
  Constructs HTTPoison header list.

  ## Options

   * `:secret_key` - Sets the `Authorization` header with a stripe Secret Key
    for this request

   * `:version` - override the `Stripe-Version` header, defaults to `2017-06-05`

   * `:stripe_account` - sets the `Stripe-Account` header for use with
    [Stripe Connect](https://stripe.com/docs/connect/authentication#stripe-account-header)

   * `:idempotency_key` - sets the
    [`Idempotency-Key` header](https://stripe.com/docs/api/idempotent_requests)
  """
  def headers(params) do
    base_headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    Enum.reduce(params, base_headers, fn
      {:secret_key, sk}, headers ->
        [{"Authorization", "Bearer #{sk}"} | headers]

      {:version, v}, headers ->
        [{"Stripe-Version", v} | headers]

      {:stripe_account, id}, headers ->
        [{"Stripe-Account", id} | headers]

      {:idempotency_key, key}, headers ->
        [{"Idempotency-Key", key} | headers]
    end)
  end

  @doc "Constructs url with query params from given data."
  def url(api_url, resource, data) do
    api_url <> resource <> "?" <> URI.encode_query(data)
  end

  @doc """
  Makes request to the Stripe API.

  Will return an HTTPoison standard response; see `parse/1`
  for decoding the response body.

  See `headers/1` for a list of options.

  ## Examples
      iex> Stripy.req(:get, "subscriptions")
      {:ok, %HTTPoison.Response{...}}

      iex> Stripy.req(:post, "customers", %{"email" => "a@b.c", "metadata[user_id]" => 1})
      {:ok, %HTTPoison.Response{...}}
  """
  def req(action, resource, data \\ %{}, opts \\ []) when action in [:get, :post, :delete] do
    if Application.get_env(:stripy, :testing, false) do
      mock_server = Application.get_env(:stripy, :mock_server, Stripy.MockServer)
      mock_server.request(action, resource, data)
    else
      header_params =
        [
          secret_key: Application.fetch_env!(:stripy, :secret_key),
          version: Application.get_env(:stripy, :version, "2017-06-05")
        ]
        |> Keyword.merge(opts)

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
