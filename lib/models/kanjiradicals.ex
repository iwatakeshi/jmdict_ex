defmodule JMDictEx.Models.RadFile do
  defmodule RadicalEntry do
    @type t :: %__MODULE__{
      code: String.t() | nil,
      kanji: [String.t()],
      stroke_count: integer()
    }
    defstruct [:code, :kanji, :stroke_count]
  end

  @type t :: %__MODULE__{
    radicals: %{String.t() => RadicalEntry.t()},
    version: String.t()
  }
  defstruct [:radicals, :version]

  def decode(json) do
    decoded = Poison.decode!(json, keys: :atoms)
    %__MODULE__{
      radicals: Map.new(decoded.radicals, fn {k, v} ->
        {k, struct(RadicalEntry, %{code: v.code, kanji: v.kanji, stroke_count: v.strokeCount})}
      end),
      version: decoded.version
    }
  end
end
