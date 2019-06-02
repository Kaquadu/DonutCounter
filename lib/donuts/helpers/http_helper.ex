defmodule Donuts.Helpers.HTTPHelper do

  def get_body(url) do
    {status, response} =
      url
      |> HTTPoison.get()
    case status do
      :error ->
        IO.puts "Cannot reach url"
        IO.puts url
        {:noreply, nil}
      _ ->
        response
          |> Map.get(:body)
          |> Poison.decode!()
    end
  end

end
