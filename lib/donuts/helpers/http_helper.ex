defmodule Donuts.Helpers.HTTPHelper do
  def get_body(url) do
    url
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Poison.decode!()
  end
end
