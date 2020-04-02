# Stripy [![hex.pm](https://img.shields.io/hexpm/v/stripy.svg?style=flat-square)](https://hex.pm/packages/stripy) [![hexdocs.pm](https://img.shields.io/badge/docs-latest-green.svg?style=flat-square)](https://hexdocs.pm/stripy)

Stripy is a micro wrapper intended to be
used for sending requests to Stripe's REST API. It is
made for developers who prefer to work directly with the
official API and provide their own abstractions on top
if such are needed.

Stripy takes care of setting headers, encoding the data,
configuration settings, etc (the usual boring boilerplate);
it also makes testing easy by letting you plug your own
mock server (see Testing section below).

Some basic examples:

```elixir
iex> Stripy.req(:get, "subscriptions")
{:ok, %HTTPoison.Response{...}}

iex> Stripy.req(:post, "customers", %{"email" => "a@b.c", "metadata[user_id]" => 1})
{:ok, %HTTPoison.Response{...}}
```

Where `subscriptions` and `customers` are [REST API resources](https://stripe.com/docs/api).

If you prefer to work with a higher-level library, check out
"stripity_stripe" or "stripe_elixir" on Hex.

## Installation

Add to your `mix.exs` as usual:
```elixir
def deps do
  [{:stripy, "~> 2.0"}]
end
```
If you're not using [application inference](https://elixir-lang.org/blog/2017/01/05/elixir-v1-4-0-released/#application-inference), then add `:stripy` to your `applications` list.

Then configure the `stripy` app per environment like so:

```elixir
config :stripy,
  secret_key: "sk_test_xxxxxxxxxxxxx", # required
  endpoint: "https://api.stripe.com/v1/", # optional
  version: "2017-06-05", # optional
  httpoison: [recv_timeout: 5000, timeout: 8000] # optional
```

You may also use environment variables:

``` elixir
config :stripy,
  secret_key: {:system, "STRIPE_SECRET_KEY"},
  endpoint: {:system, "STRIPE_ENDPOINT"},
  version: {:system, "STRIPE_VERSION"}
```

## Testing

You can disable actual calls to the Stripe API like so:

```elixir
# Usually in your test.exs.
config :stripy,
  testing: true
```

All functions that use Stripy would receive response `{:ok, %{status_code: 200, body: "{}"}}`.

To provide your own responses, you need to configure a mock server:

```elixir
config :stripy,
  testing: true,
  mock_server: MyApp.StripeMockServer
```

Here's an example mock server that mocks the `/customer` endpoint and returns a basic
object for a customer with id `cus_test`

```elixir
defmodule MyApp.StripeMockServer do
  @behaviour Stripy.MockServer

  @ok_res %{status_code: 200}

  @impl Stripy.MockServer
  def request(:get, "customers/cus_test", %{}) do
    body = Poison.encode!(%{"email" => "email@email.com"})
    {:ok, Map.put(@ok_res, :body, body)}
  end
end
```

Now let's quickly write a naive function that gets user's billing email:

```elixir
def stripe_email(user) do
  {:ok, res} = Stripy.req(:get, "customers/#{user.stripe_id}")
  res["email"]
end
```

We can test it like so:

```elixir
fake_user = %{stripe_id: "cus_test"}
assert stripe_email(fake_user) == "email@email.com"
```

## Custom headers

You can add custom headers to the request by supplying a fourth parameter:

```elixir
Stripy.req(:post, "charges", %{amount: 1000}, %{"Idempotency-Key" => "123456"})
```

## License

- Stripy: See LICENSE file.
