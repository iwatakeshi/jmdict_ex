defmodule JMDictEx.Loaders.JMDict do
  use JMDictEx.Loaders.Macro, source: :jmdict, decoder: JMDictEx.Decoders.JMDict
end
