defmodule JMDictEx.Models.KanjiDic2 do
  @derive [Poison.Encoder]
  @type t :: %__MODULE__{
          characters: [Character.t()],
          database_version: String.t(),
          dict_date: String.t(),
          file_version: integer(),
          languages: [String.t()],
          version: String.t()
        }
  defstruct [:characters, :database_version, :dict_date, :file_version, :languages, :version]

  defmodule Character do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            codepoints: [Codepoint.t()],
            dictionary_references: [DictionaryReference.t()],
            literal: String.t(),
            misc: Misc.t(),
            query_codes: [QueryCode.t()],
            radicals: [Radical.t()],
            reading_meaning: ReadingMeaning.t()
          }
    defstruct [
      :codepoints,
      :dictionary_references,
      :literal,
      :misc,
      :query_codes,
      :radicals,
      :reading_meaning
    ]
  end

  defmodule Codepoint do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            type: String.t(),
            value: String.t()
          }
    defstruct [:type, :value]
  end

  defmodule DictionaryReference do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            morohashi: integer() | nil,
            type: String.t(),
            value: String.t()
          }
    defstruct [:morohashi, :type, :value]
  end

  defmodule Variant do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            type: String.t(),
            value: String.t()
          }
    defstruct [:type, :value]
  end

  defmodule Misc do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            frequency: integer() | nil,
            grade: integer() | nil,
            jlpt_level: integer() | nil,
            radical_names: [String.t()],
            stroke_counts: [integer()],
            variants: [Variant.t()]
          }
    defstruct [:frequency, :grade, :jlpt_level, :radical_names, :stroke_counts, :variants]
  end

  defmodule QueryCode do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            skip_misclassification: String.t() | nil,
            type: String.t(),
            value: String.t()
          }
    defstruct [:skip_misclassification, :type, :value]
  end

  defmodule Radical do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            type: String.t(),
            value: integer()
          }
    defstruct [:type, :value]
  end

  defmodule Meaning do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            lang: String.t(),
            value: String.t()
          }
    defstruct [:lang, :value]
  end

  defmodule Reading do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            on_type: String.t() | nil,
            status: String.t() | nil,
            type: String.t(),
            value: String.t()
          }
    defstruct [:on_type, :status, :type, :value]
  end

  defmodule ReadingMeaningGroup do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            meanings: [Meaning.t()],
            readings: [Reading.t()]
          }
    defstruct [:meanings, :readings]
  end

  defmodule ReadingMeaning do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            groups: [ReadingMeaningGroup.t()],
            nanori: [String.t()]
          }
    defstruct [:groups, :nanori]
  end
end
