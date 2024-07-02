defmodule JMDictEx.Decoders.Kradfile do
  alias JMDictEx.Models.Kradfile
  alias JMDictEx.Models.Kradfile.KanjiComponents

  def decode(json) do
    case Poison.decode(json, as: %Kradfile{}) do
      {:ok, decoded} ->
        result = %{decoded | kanji: transform_kanji_components(decoded.kanji)}
        {:ok, result}
      {:error, _} -> {:error, "Failed to decode Kradfile" }
    end
  end

  defp transform_kanji_components(kanji) when is_map(kanji) do
    Enum.map(kanji, fn {key, value} ->
      components = if is_list(value), do: value, else: []
      {key, %KanjiComponents{components: components}}
    end)
    |> Enum.into(%{})
  end
  # defp transform_kanji_components(_), do: %{}

end
