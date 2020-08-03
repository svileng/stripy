# Changelog

# 2.1.0 (2020-02-11)
## New features
- Allow fetching config at runtime, for example `{:system, "ENV_VAR"}` in `config.exs`

# 2.0.0 (2020-02-11)
## Breaking changes
- Removed `headers/1` in favour of new `req/4` (see below)
- Bumped required version of Elixir to `~> 1.7`

## New features
- `req/4` accepts a fourth optional parameter that allows you to send extra
headers to Stripe, e.g.

```elixir
%{"Stripe-Account" => "...", "Idempotency-Key" => "..."}
```

# 1.2.1 (2018-12-05)
- Relaxed `HTTPoison` dependency version.

# 1.2.0 (2018-03-16)
- Introducing `testing` mode and `Stripy.MockServer` behaviour for easier testing.

# 1.1.0 (2018-03-15)
- Ability to pass options to HTTPoison through the `httpoison` config.

# 1.0.0
- First version
