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

  @content_type_header %{"Content-Type" => "application/x-www-form-urlencoded"}

  @doc "Constructs url with query params from given data."
  def url(api_url, resource, data) do
    api_url <> resource <> "?" <> URI.encode_query(data)
  end

  @doc """
  Makes request to the Stripe API.

  Will return an HTTPoison standard response; see `parse/1`
  for decoding the response body.

  You can specify custom headers to be included in the request
  to Stripe, such as `Idempotency-Key`, `Stripe-Account` or any
  other header. Just pass a map as the fourth argument.
  See example below.

  ## Examples
      iex> Stripy.req(:get, "subscriptions")
      {:ok, %HTTPoison.Response{...}}

      iex> Stripy.req(:post, "customers", %{"email" => "a@b.c", "metadata[user_id]" => 1})
      {:ok, %HTTPoison.Response{...}}

      iex> Stripy.req(:post, "customers", %{"email" => "a@b.c"}, %{"Idempotency-Key" => "ABC"})
      {:ok, %HTTPoison.Response{...}}
  """
  def req(action, resource, data \\ %{}, headers \\ %{}) when action in [:get, :post, :delete] do
    if Application.get_env(:stripy, :testing, false) do
      mock_server = Application.get_env(:stripy, :mock_server, Stripy.MockServer)
      mock_server.request(action, resource, data)
    else
      secret_key = get_config!(:secret_key)

      headers =
        @content_type_header
        |> Map.merge(%{
          "Authorization" => "Bearer #{secret_key}",
          "Stripe-Version" => get_config(:version, "2017-06-05")
        })
        |> Map.merge(headers)
        |> Map.to_list()

      api_url = get_config(:endpoint, "https://api.stripe.com/v1/")

      options = Application.get_env(:stripy, :httpoison, [])

      url = url(api_url, resource, data)
      HTTPoison.request(action, url, "", headers, options)
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

  defp get_config(key, default \\ nil) when is_atom(key) do
    case Application.fetch_env(:stripy, key) do
      {:ok, {:system, env_var}} -> System.get_env(env_var)
      {:ok, value} -> value
      :error -> default
    end
  end

  defp get_config!(key) do
    get_config(key) || raise "stripy config #{key} is required"
  end
end
