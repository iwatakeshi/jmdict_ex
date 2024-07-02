defmodule JMDictEx.Decoders.JMDict do
  alias JMDictEx.Models.JMDict
  alias JMDictEx.Models.JMDict.{Word, Sense, Kana, Kanji, Gloss}

  defimpl Poison.Decoder, for: JMDict do
    def decode(dict, _options) do
      %{dict | words: Enum.map(dict.words, &JMDictEx.Decoders.JMDict.decode_word/1)}
    end
  end

  defimpl Poison.Decoder, for: Word do
    def decode(word, _options) do
      %{
        word
        | kana: Enum.map(word.kana, &struct(Kana, &1)),
          kanji: Enum.map(word.kanji, &struct(Kanji, &1)),
          sense: Enum.map(word.sense, &Poison.Decoder.decode(&1, []))
      }
    end
  end

  defimpl Poison.Decoder, for: Sense do
    def decode(sense, _options) do
      %{sense | gloss: Enum.map(sense.gloss, &struct(Gloss, &1))}
    end
  end

  # Helper functions
  def decode_word(word) do
    %{
      word
      | kana: Enum.map(word.kana, &struct(Kana, &1)),
        kanji: Enum.map(word.kanji, &struct(Kanji, &1)),
        sense: Enum.map(word.sense, &decode_sense/1)
    }
  end

  def decode_sense(sense) do
    %{sense | gloss: Enum.map(sense.gloss, &struct(Gloss, &1))}
  end

  def decode(dict), do: Poison.decode(dict, as: JMDict)
end
