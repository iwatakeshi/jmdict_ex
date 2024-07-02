defmodule JMDictEx.Decoders.Kradfile do
  alias Kradfile
  alias Kradfile.KanjiComponents

  # Helper function
  def decode_kanji_components(kanji_map) do
    Map.new(kanji_map, fn {k, v} ->
      {k, struct(KanjiComponents, components: v)}
    end)
  end

  # Poison.Decoder implementations
  defimpl Poison.Decoder, for: Kradfile do
    def decode(kradfile, _options) do
      %{kradfile | kanji: JMDictEx.Decoders.Kradfile.decode_kanji_components(kradfile.kanji)}
    end
  end

  def decode(kradfile), do: Poison.decode(kradfile, as: Kradfile)
end
