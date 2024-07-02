defmodule JMDictEx.Loaders.JMDict do
  require Logger
  alias JMDictEx.Utils.Downloader
  import JMDictEx.Utils.Cachex, only: :functions

  @cache_ttl :timer.hours(24)

  def load(), do: load(:eng)

  def load(lang, format \\ :zip) when is_atom(lang) and is_atom(format) do
    if lang not in available_languages() do
      IO.puts("Invalid language: #{inspect(lang)}")
      {:error, "Invalid language: #{inspect(lang)}"}
    else
      Cachex.fetch(
        :jmdict_ex,
        {:jmdict, :load, lang},
        fn _ -> do_load(lang, format) |> unwrap(%{}) end,
        ttl: @cache_ttl
      )
      |> unwrap()
    end
  end

  def available_languages do
    case Downloader.fetch_dicts(source: :jmdict) do
      {:ok, assets} ->
        assets
        |> Downloader.available_languages()

      {:error, _} ->
        []
    end
  end

  defp do_load(lang, format) do
    Logger.info("Downloading JMDict (#{lang})...")

    with {:ok, assets} <- Downloader.fetch_dicts(source: :jmdict, lang: lang, format: format),
         {:ok, dir} <- Briefly.create(type: :directory),
         {:ok, path} <- Downloader.download_to(assets, dir),
         {:ok, [file]} <- File.ls(path),
         {:ok, binary} <- File.read(Path.join(path, file)),
         {:ok, result} <- JMDictEx.Models.JMDict.decode(binary) do
      Briefly.cleanup()
      {:ok, result}
    else
      {:error, reason} ->
        Briefly.cleanup()
        {:error, reason}

      _error ->
        Briefly.cleanup()
        {:error, :unknown}
    end
  end
end
