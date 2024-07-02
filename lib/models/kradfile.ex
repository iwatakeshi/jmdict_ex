defmodule Kradfile do
  @derive [Poison.Encoder]
  @type t :: %__MODULE__{
          kanji: %{String.t() => KanjiComponents.t()},
          version: String.t()
        }
  defstruct [:kanji, :version]

  defmodule KanjiComponents do
    @derive [Poison.Encoder]
    @type t :: %__MODULE__{
            components: [String.t()]
          }
    defstruct [:components]
  end
end
