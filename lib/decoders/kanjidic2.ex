defmodule JMDictEx.Decoders.KanjiDic2 do
  alias JMDictEx.Models.KanjiDic2

  alias JMDictEx.Models.KanjiDic2.{
    Character,
    Codepoint,
    DictionaryReference,
    Variant,
    Misc,
    QueryCode,
    Radical,
    Meaning,
    Reading,
    ReadingMeaningGroup,
    ReadingMeaning
  }

  # Helper functions
  def decode_character(char) do
    %{
      char
      | codepoints: Enum.map(char.codepoints, &struct(Codepoint, &1)),
        dictionary_references:
          Enum.map(char.dictionary_references, &struct(DictionaryReference, &1)),
        misc: decode_misc(char.misc),
        query_codes: Enum.map(char.query_codes, &struct(QueryCode, &1)),
        radicals: Enum.map(char.radicals, &struct(Radical, &1)),
        reading_meaning: decode_reading_meaning(char.reading_meaning)
    }
  end

  def decode_misc(misc) do
    %{misc | variants: Enum.map(misc.variants, &struct(Variant, &1))}
  end

  def decode_reading_meaning(rm) do
    %{rm | groups: Enum.map(rm.groups, &decode_reading_meaning_group/1)}
  end

  def decode_reading_meaning_group(group) do
    %{
      group
      | meanings: Enum.map(group.meanings, &struct(Meaning, &1)),
        readings: Enum.map(group.readings, &struct(Reading, &1))
    }
  end

  # Poison.Decoder implementations
  defimpl Poison.Decoder, for: KanjiDic2 do
    def decode(dict, _options) do
      %{
        dict
        | characters: Enum.map(dict.characters, &JMDictEx.Decoders.KanjiDic2.decode_character/1)
      }
    end
  end

  defimpl Poison.Decoder, for: Character do
    def decode(char, _options) do
      JMDictEx.Decoders.KanjiDic2.decode_character(char)
    end
  end

  defimpl Poison.Decoder, for: Misc do
    def decode(misc, _options) do
      JMDictEx.Decoders.KanjiDic2.decode_misc(misc)
    end
  end

  defimpl Poison.Decoder, for: ReadingMeaning do
    def decode(rm, _options) do
      JMDictEx.Decoders.KanjiDic2.decode_reading_meaning(rm)
    end
  end

  defimpl Poison.Decoder, for: ReadingMeaningGroup do
    def decode(group, _options) do
      JMDictEx.Decoders.KanjiDic2.decode_reading_meaning_group(group)
    end
  end

  def decode(dict), do: Poison.decode(dict, as: KanjiDic2)
end
