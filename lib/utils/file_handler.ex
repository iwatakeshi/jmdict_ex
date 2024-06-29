defmodule JMDictEx.Utils.FileHandler do
  @moduledoc """
  Utility module for handling file operations.
  """

  @doc """
  Saves a binary to a file.

  ## Parameters

    - binary: The binary data to save.
    - file_path: The path where the file should be saved.

  ## Returns

    - {:ok, file_path} if the file was successfully saved.
    - {:error, reason} if there was an error saving the file.
  """
  @spec save_binary(binary(), String.t()) :: {:ok, String.t()} | {:error, term()}
  def save_binary(binary, file_path) do
    with :ok <- File.write(file_path, binary) do
      {:ok, file_path}
    else
      # coveralls-ignore-next-line
      {:error, reason} -> {:error, "Failed to save file: #{inspect(reason)}"}
    end
  end
end
