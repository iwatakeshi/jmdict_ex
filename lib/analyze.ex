defmodule JsonShapeAnalyzer do
  def analyze(file_path) do
    with {:ok, content} <- File.read(file_path),
         {:ok, json} <- Poison.decode(content) do
      get_shape(json)
    else
      {:error, reason} -> "Error: #{reason}"
    end
  end

  def analyze_and_save(file_path, output_path \\ "shape.txt") do
    shape = analyze(file_path)
    case File.write(output_path, shape) do
      :ok -> {:ok, "Shape analysis saved to #{output_path}"}
      {:error, reason} -> {:error, "Failed to save shape analysis: #{reason}"}
    end
  end

  defp get_shape(data, prefix \\ "") do
    case data do
      map when is_map(map) ->
        object_shape = map
        |> Enum.map(fn {key, value} ->
          "#{prefix}  #{key}:\n#{get_shape(value, prefix <> "    ")}"
        end)
        |> Enum.join("\n")
        "#{prefix}Object:\n#{object_shape}"

      list when is_list(list) ->
        if length(list) > 0 do
          "#{prefix}Array:\n#{get_shape(List.first(list), prefix <> "  ")}"
        else
          "#{prefix}Array: (empty)"
        end

      value when is_binary(value) -> "#{prefix}String"
      value when is_integer(value) -> "#{prefix}Integer"
      value when is_float(value) -> "#{prefix}Float"
      true -> "#{prefix}Boolean"
      false -> "#{prefix}Boolean"
      nil -> "#{prefix}Null"
    end
  end
end
