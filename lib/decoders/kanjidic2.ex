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

  def decode(json) do
    Poison.decode(json,
      as: %KanjiDic2{
        characters: [
          %Character{
            codepoints: [%Codepoint{}],
            dictionary_references: [%DictionaryReference{}],
            misc: %Misc{
              variants: [%Variant{}]
            },
            query_codes: [%QueryCode{}],
            radicals: [%Radical{}],
            reading_meaning: %ReadingMeaning{
              groups: [
                %ReadingMeaningGroup{
                  meanings: [%Meaning{}],
                  readings: [%Reading{}]
                }
              ]
            }
          }
        ]
      }
    )
  end
end
