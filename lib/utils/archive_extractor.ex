defmodule JMDictEx.Utils.ArchiveExtractor do
  @moduledoc """
  Utility module for extracting archives.
  """

  @doc """
  Extracts an archive file based on its type.

  ## Parameters

    - file_path: The path to the archive file.
    - output_dir: The directory where the contents should be extracted.

  ## Returns

    - {:ok, output_dir} if the archive was successfully extracted.
    - {:error, reason} if there was an error during extraction.
  """
  @spec extract(String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def extract(file_path, output_dir) do
    case get_archive_type(file_path) do
      :zip -> extract_zip(file_path, output_dir)
      :tgz -> extract_tgz(file_path, output_dir)
      :unknown -> {:error, "Unknown archive type"}
    end
  end

  defp get_archive_type(file_path) do
    cond do
      String.ends_with?(file_path, ".zip") -> :zip
      String.ends_with?(file_path, ".tgz") -> :tgz
      true -> :unknown
    end
  end

  defp extract_zip(file_path, output_dir) do
    case :zip.extract(String.to_charlist(file_path), [{:cwd, String.to_charlist(output_dir)}]) do
      {:ok, _} -> {:ok, output_dir}
      {:error, reason} -> {:error, "Failed to extract ZIP: #{inspect(reason)}"}
    end
  end

  defp extract_tgz(file_path, output_dir) do
    try do
      :erl_tar.extract(String.to_charlist(file_path), [
        :compressed,
        {:cwd, String.to_charlist(output_dir)}
      ])

      {:ok, output_dir}
    rescue
      # coveralls-ignore-next-line
      e -> {:error, "Failed to extract TGZ: #{inspect(e)}"}
    end
  end
end
