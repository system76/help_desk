defmodule HelpDesk.BroadwayHelpers do
  def bottled_message(resource) do
    [resource: resource]
    |> Bottle.Core.V1.Bottle.new()
    |> Bottle.Core.V1.Bottle.encode()
    |> URI.encode()
  end

  def test_message(message), do: Broadway.test_message(HelpDesk.Broadway, message)
end
