defmodule JMDictEx.Loaders.JMNEDict do
  use JMDictEx.Loaders.Macro, source: :jmnedict, decoder: JMDictEx.Decoders.JMNEDict
end
