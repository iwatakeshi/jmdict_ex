defmodule JMDictEx.Decoders.JMNEDict do
  alias JMDictEx.Models.JMNEDict
  alias JMDictEx.Models.JMNEDict.{Word, TranslationGroup, Translation, Kana, Kanji}

  # Helper functions
  def decode_word(word) do
    %{
      word
      | kana: Enum.map(word.kana, &struct(Kana, &1)),
        kanji: Enum.map(word.kanji, &struct(Kanji, &1)),
        translation: Enum.map(word.translation, &decode_translation_group/1)
    }
  end

  def decode_translation_group(group) do
    %{group | translation: Enum.map(group.translation, &struct(Translation, &1))}
  end

  # Poison.Decoder implementations
  defimpl Poison.Decoder, for: JMNEDict do
    def decode(dict, _options) do
      %{dict | words: Enum.map(dict.words, &JMDictEx.Decoders.JMNEDict.decode_word/1)}
    end
  end

  defimpl Poison.Decoder, for: Word do
    def decode(word, _options) do
      JMDictEx.Decoders.JMNEDict.decode_word(word)
    end
  end

  defimpl Poison.Decoder, for: TranslationGroup do
    def decode(group, _options) do
      JMDictEx.Decoders.JMNEDict.decode_translation_group(group)
    end
  end

  def decode(dict), do: Poison.decode(dict, as: JMNEDict)
end
