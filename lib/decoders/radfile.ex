defmodule JMDictEx.Decoders.Radkfile do
  alias JMDictEx.Models.Radkfile
  alias JMDictEx.Models.Radkfile.RadicalEntry

  # Helper function
  def decode_radicals(radicals_map) do
    Map.new(radicals_map, fn {k, v} ->
      {k, struct(RadicalEntry, v)}
    end)
  end

  # Poison.Decoder implementations
  defimpl Poison.Decoder, for: Radkfile do
    def decode(radfile, _options) do
      %{radfile | radicals: JMDictEx.Decoders.Radkfile.decode_radicals(radfile.radicals)}
    end
  end

  def decode(radfile), do: Poison.decode(radfile, as: Radkfile)
end
