defmodule JMDictEx.Loaders.Core do
  require Logger

  alias JMDictEx.Utils.Downloader
  import JMDictEx.Utils.Cachex, only: :functions

  @dialyzer {:no_return, do_load: 4}
  @dialyzer {:nowarn_function, function_with_anon: 0}

  @ttl Application.compile_env(:jmdict_ex, :cache_ttl, 86400)

  def load(source, lang, format, decode_fun)
      when is_atom(source) and
             is_atom(lang) and
             is_atom(format) and
             is_function(decode_fun, 1) do
    if length(available_languages(source)) > 0 and not valid_language?(source, lang) do
      Logger.error("Invalid language: #{inspect(lang)}")
      {:error, "Invalid language: #{inspect(lang)}"}
    else
      Cachex.fetch(
        :jmdict_ex,
        {source, :load, lang, format},
        fn _ -> do_load(source, lang, format, decode_fun) |> wrap() end,
        ttl: @ttl
      )
      |> unwrap(%{})
    end
  end

  defp do_load(source, lang, format, decode_fun) do
    debug_output =
      if lang,
        do: "Loading #{source} data for #{inspect(lang)} in #{inspect(format)} format",
        else: "Loading #{source} data in #{inspect(format)} format"

    Logger.debug(debug_output)

    with {:ok, assets} <- Downloader.fetch_dicts(source: source, lang: lang, format: format),
         {:ok, dir} <- Briefly.create(type: :directory),
         {:ok, path} <- Downloader.download_to(assets, dir),
         {:ok, [file]} <- File.ls(path),
         {:ok, binary} <- File.read(Path.join(path, file)),
         {:ok, result} <- decode_fun.(binary) do
      Briefly.cleanup()
      {:ok, result}
    else
      {:error, reason} ->
        Logger.error("Failed to load #{source} data: #{inspect(reason)}")
        Briefly.cleanup()
        {:error, reason}

      error ->
        Logger.error("Failed to load #{source} data: #{inspect(error)}")
        Briefly.cleanup()
        {:error, :unknown}
    end
  end

  def available_languages(source) when is_atom(source) do
    case Downloader.fetch_dicts(source: source) do
      {:ok, assets} ->
        result =
          assets
          |> Downloader.available_languages()

        case result do
          [:unknown] -> []
          _ -> result
        end

      {:error, _} ->
        []
    end
  end

  def valid_language?(source, lang) when is_atom(source) and is_atom(lang) do
    available_languages(source)
    |> Enum.member?(lang)
  end
end
