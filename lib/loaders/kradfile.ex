defmodule JMDictEx.Loaders.Kradfile do
  use JMDictEx.Loaders.Macro,
    source: :kradfile,
    decoder: JMDictEx.Decoders.Kradfile,
    has_language: false
end
