defmodule Kradfile do
  defmodule KanjiComponents do
    @type t :: %__MODULE__{
      components: [String.t()]
    }
    defstruct [:components]
  end

  @type t :: %__MODULE__{
    kanji: %{String.t() => KanjiComponents.t()},
    version: String.t()
  }
  defstruct [:kanji, :version]

  def decode(json) do
    decoded = Poison.decode!(json, keys: :atoms)
    %__MODULE__{
      kanji: Map.new(decoded.kanji, fn {k, v} ->
        {k, struct(KanjiComponents, components: v)}
      end),
      version: decoded.version
    }
  end
end
