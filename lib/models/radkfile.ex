defmodule JMDictEx.Models.Radkfile do
  @derive [Poison.Encoder]
  @type t :: %__MODULE__{
          radicals: %{String.t() => RadicalEntry.t()},
          version: String.t()
        }
  defstruct [:radicals, :version]

  defmodule RadicalEntry do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            code: String.t() | nil,
            kanji: [String.t()],
            stroke_count: integer()
          }
    defstruct [:code, :kanji, :stroke_count]
  end
end
