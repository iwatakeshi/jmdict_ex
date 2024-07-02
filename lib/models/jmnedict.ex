defmodule JMDictEx.Models.JMNEDict do
  defmodule Translation do
    @type t :: %__MODULE__{
      lang: String.t(),
      text: String.t()
    }
    defstruct [:lang, :text]
  end

  defmodule TranslationGroup do
    @type t :: %__MODULE__{
      related: [String.t()],
      translation: [Translation.t()],
      type: [String.t()]
    }
    defstruct [:related, :translation, :type]
  end

  defmodule Kana do
    @type t :: %__MODULE__{
      applies_to_kanji: [String.t()],
      tags: [String.t()],
      text: String.t()
    }
    defstruct [:applies_to_kanji, :tags, :text]
  end

  defmodule Kanji do
    @type t :: %__MODULE__{
      tags: [String.t()],
      text: String.t()
    }
    defstruct [:tags, :text]
  end

  defmodule Word do
    @type t :: %__MODULE__{
      id: String.t(),
      kana: [Kana.t()],
      kanji: [Kanji.t()],
      translation: [TranslationGroup.t()]
    }
    defstruct [:id, :kana, :kanji, :translation]
  end

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

  def decode(json) do
    Poison.decode!(json,
      as: %__MODULE__{
        dict_revisions: [],
        languages: [],
        tags: %{},
        words: [%Word{
          kana: [%Kana{}],
          kanji: [%Kanji{}],
          translation: [%TranslationGroup{
            translation: [%Translation{}]
          }]
        }]
      }
    )
  end
end