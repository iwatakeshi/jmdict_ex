defmodule JMDictEx.Models.JMDict do
  @derive [Poison.Encoder]
  @type t :: %__MODULE__{
          common_only: boolean(),
          dict_date: String.t(),
          dict_revisions: [String.t()],
          languages: [String.t()],
          tags: %{String.t() => String.t()},
          version: String.t(),
          words: [Word.t()]
        }
  defstruct [:common_only, :dict_date, :dict_revisions, :languages, :tags, :version, :words]

  defmodule Gloss do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            gender: String.t() | nil,
            lang: String.t(),
            text: String.t(),
            type: String.t() | nil
          }
    defstruct [:gender, :lang, :text, :type]
  end

  defmodule Sense do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            antonym: [String.t()],
            applies_to_kana: [String.t()],
            applies_to_kanji: [String.t()],
            dialect: [String.t()],
            field: [String.t()],
            gloss: [Gloss.t()],
            info: [String.t()],
            language_source: [String.t()],
            misc: [String.t()],
            part_of_speech: [String.t()],
            related: [[String.t()]]
          }
    defstruct [
      :antonym,
      :applies_to_kana,
      :applies_to_kanji,
      :dialect,
      :field,
      :gloss,
      :info,
      :language_source,
      :misc,
      :part_of_speech,
      :related
    ]
  end

  defmodule Kana do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            applies_to_kanji: [String.t()],
            common: boolean(),
            tags: [String.t()],
            text: String.t()
          }
    defstruct [:applies_to_kanji, :common, :tags, :text]
  end

  defmodule Kanji do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            common: boolean(),
            text: String.t()
          }
    defstruct [:common, :text]
  end

  defmodule Word do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            id: String.t(),
            kana: [Kana.t()],
            kanji: [Kanji.t()],
            sense: [Sense.t()]
          }
    defstruct [:id, :kana, :kanji, :sense]
  end
end
