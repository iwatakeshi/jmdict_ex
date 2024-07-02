defmodule JMDictEx.Loaders.Radkfile do
  use JMDictEx.Loaders.Macro,
    source: :radkfile,
    decoder: JMDictEx.Decoders.Radkfile,
    has_language: false
end
