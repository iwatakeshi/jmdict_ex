defmodule JMDictEx.Decoders.Radkfile do
  alias JMDictEx.Models.Radkfile
  alias JMDictEx.Models.Radkfile.RadicalEntry

   def decode(json) do
    case Poison.decode(json, as: %Radkfile{
      radicals: %{}
    }) do
      {:ok, decoded} ->
        result = %{decoded | radicals: transform_radicals(decoded.radicals)}
        {:ok, result}
      {:error, _} -> {:error, "Failed to decode Radkfile" }
    end

  end

  defp transform_radicals(radicals) when is_map(radicals) do
    Enum.map(radicals, fn {key, value} ->
      {key, struct(RadicalEntry, %{
        code: Map.get(value, "code"),
        kanji: Map.get(value, "kanji", []),
        stroke_count: Map.get(value, "strokeCount")
      })}
    end)
    |> Enum.into(%{})
  end
  # defp transform_radicals(_), do: %{}
end
