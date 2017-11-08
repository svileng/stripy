# Stripy [![hex.pm](https://img.shields.io/hexpm/v/stripy.svg?style=flat-square)](https://hex.pm/packages/stripy) [![hexdocs.pm](https://img.shields.io/badge/docs-latest-green.svg?style=flat-square)](https://hexdocs.pm/stripy)

Stripy is a micro wrapper intended to be
used for sending requests to Stripe's REST API. It is
made for developers who prefer to work directly with the
official API and provide their own abstractions on top
if such are needed.

Stripy takes care of setting headers, encoding the data,
configuration settings, etc (the usual boring boilerplate);
it also provides a `parse/1` helper function for decoding.

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
  [{:stripy, "~> 1.0"}]
end
```
If you're not using [application inference](https://elixir-lang.org/blog/2017/01/05/elixir-v1-4-0-released/#application-inference), then add `:stripy` to your `applications` list.

Then configure the `stripy` app per environment like so:

```elixir
config :stripy,
  secret_key: "sk_test_xxxxxxxxxxxxx", # required
  endpoint: "https://api.stripe.com/v1/", # optional
  version: "2017-06-05" # optional
```

## About

<img src="https://app.heresy.io/images/logo-dark.svg" height="50px">

This project is sponsored by [Heresy](http://heresy.io). We're always looking for great engineers to join our team, so if you love Elixir, open source and enjoy some challenge, drop us a line and say hello!

## License

- Stripy: See LICENSE file.
- "Heresy" name and logo: Copyright © 2017 Heresy Software Ltd
