defmodule JMDictEx.Decoders.JMNEDict do
  alias JMDictEx.Models.JMNEDict
  alias JMDictEx.Models.JMNEDict.{Word, TranslationGroup, Translation, Kana, Kanji}

  def decode(json) do
    Poison.decode(json,
      as: %JMNEDict{
        words: [
          %Word{
            kana: [%Kana{}],
            kanji: [%Kanji{}],
            translation: [
              %TranslationGroup{
                translation: [%Translation{}]
              }
            ]
          }
        ]
      }
    )
  end
end
