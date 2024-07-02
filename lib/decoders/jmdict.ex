defmodule JMDictEx.Decoders.JMDict do
  alias JMDictEx.Models.JMDict
  alias JMDictEx.Models.JMDict.{Word, Sense, Kana, Kanji, Gloss}

  def decode(json) do
    Poison.decode(json,
      as: %JMDict{
        words: [
          %Word{
            kana: [%Kana{}],
            kanji: [%Kanji{}],
            sense: [
              %Sense{
                gloss: [%Gloss{}]
              }
            ]
          }
        ]
      }
    )
  end
end
