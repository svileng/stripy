defmodule Stripy.MockServer do
  @moduledoc """
  Mock server that would always return an empty, successful reply.

  Implement behaviour to provide your own responses; make sure the
  reply is an ok/error tuple, something resembling
  a real HTTPoison result. Body of the response should also be
  JSON encoded.
  """

  @doc "Request made by client."
  @callback request(atom, String.t(), map) :: tuple

  def request(action, resource, body) do
    IO.puts("Stripy.MockServer #{to_string(action)} #{resource} #{inspect(body)}")
    {:ok, %{status_code: 200, body: "{}"}}
  end
end
