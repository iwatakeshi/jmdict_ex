defmodule JMDictEx.Utils.Downloader do
  @moduledoc """
  Provides functionality for fetching, filtering, and downloading JMDict dictionaries.

  This module allows users to:
  - Fetch the latest dictionary assets from the jmdict-simplified GitHub repository
  - Filter assets by source type, language, and archive type
  - Download and extract selected assets to a specified destination

  It supports various dictionary types (JMDict, JMnedict, Kanjidic2, etc.) and multiple languages.
  """

  alias JMDictEx.Models.Release.Asset
  alias JMDictEx.Utils.GitHub.Releases.Assets
  alias JMDictEx.Utils.FileHandler
  alias JMDictEx.Utils.ArchiveExtractor

  import JMDictEx.Utils.Cachex, only: :functions

  @cache_name :jmdict_ex
  # Cache for 24 hours
  @cache_ttl :timer.hours(24)

  @languages [
    all: :all,
    eng: :eng,
    dut: :dut,
    fre: :fre,
    ger: :ger,
    hun: :hun,
    rus: :rus,
    slv: :slv,
    spa: :spa,
    swe: :swe
  ]
  @eng_variants [eng_common: :eng_common]

  @sources [:jmdict, :jmnedict, :kanjidic2, :kradfile, :radkfile]

  @doc """
  Returns a list of all available languages for dictionary assets.
  """
  def available_languages, do: Keyword.values(@languages ++ @eng_variants)

  @spec available_languages([Asset.t()]) :: [atom()]
  def available_languages(assets) when is_list(assets) do
    cache_key = {:download_available_languages, assets}

    Cachex.fetch(
      @cache_name,
      cache_key,
      fn ->
        assets
        |> Enum.map(&infer_lang(&1.name))
        |> Enum.uniq()
        |> wrap()
      end,
      ttl: @cache_ttl
    )
    |> unwrap([])
    |> elem(1)
  end

  @doc """
  Returns a list of all available source types for dictionary assets.
  """
  def available_sources, do: @sources

  def available_formats(assets) when is_list(assets) do
    cache_key = {:download_available_formats, assets}

    Cachex.fetch(
      @cache_name,
      cache_key,
      fn ->
        assets
        |> Enum.map(&infer_archive_format(&1.browser_download_url))
        |> Enum.uniq()
        |> wrap()
      end,
      ttl: @cache_ttl
    )
    |> unwrap()
  end

  @doc """
  Fetches and filters dictionary assets based on provided options.

  ## Options

    * `:source` - The source type of the dictionary (e.g., :jmdict, :jmnedict)
    * `:lang` - The language of the dictionary (e.g., :eng, :fre, :all)
    * `:archive_type` - The archive type of the asset (:tgz or :zip)

  ## Returns

    * `{:ok, [Asset.t()]}` - A list of filtered assets
    * `{:error, String.t()}` - An error message if fetching fails
  """
  @type fetch_opts :: [source: atom(), lang: atom(), archive_type: :tgz | :zip]
  @spec fetch_dicts(fetch_opts()) :: {:ok, [Asset.t()]} | {:error, String.t()}
  def fetch_dicts(opts) when is_list(opts) do
    cache_key = {:download_fetch_dicts, opts}

    Cachex.fetch(
      @cache_name,
      cache_key,
      fn ->
        with {:ok, assets} <- get_latest_assets() do
          apply_filter(assets, opts) |> wrap()
        else
          # coveralls-ignore-next-line
          {:error, _} -> wrap({:ok, []})
        end
      end,
      ttl: @cache_ttl
    )
    |> unwrap()
  end

  @doc """
  Downloads and extracts one or more assets to the specified destination.

  ## Parameters

    * `asset_or_assets` - A single asset, a list of assets, or the result of `fetch_dicts/1`
    * `dest` - The destination directory for extracted files

  ## Returns

    * `{:ok, String.t()}` - The path of the extracted directory for a single asset
    * `[{:ok, String.t()} | {:error, String.t()}]` - A list of results for multiple assets
    * `{:error, String.t()}` - An error message if the download or extraction fails
  """
  @spec download_to(
          {:ok, Asset.t()}
          | {:ok, [Asset.t()]}
          | {:error, String.t()}
          | [Asset.t()]
          | Asset.t()
          | [],
          String.t()
        ) ::
          {:ok, String.t()}
          | {:error, String.t()}
          | [{:ok, String.t()} | {:error, String.t()}]
  # coveralls-ignore-start
  def download_to({:ok, asset}, dest) when is_struct(asset, Asset) and is_binary(dest),
    do: download_to(asset, dest)

  def download_to({:ok, assets}, dest) when is_list(assets) and is_binary(dest),
    do: assets |> Enum.map(&download_to(&1, dest))

  def download_to({:error, reason}, _dest), do: {:error, reason}
  def download_to([%Asset{} = asset], dest), do: download_to(asset, dest)

  def download_to(assets, dest) when is_list(assets) and is_binary(dest) do
    assets
    |> Task.async_stream(
      fn asset -> download_to(asset, dest) end,
      max_concurrency: 5,
      timeout: :infinity
    )
    |> Enum.map(fn {:ok, result} -> result end)
  end

  def download_to([], _dest), do: {:error, "No assets to download"}
  # coveralls-ignore-end

  def download_to(%Asset{} = asset, dest) do
    cache_key = {:download_download_to, asset, dest}

    Cachex.fetch(
      @cache_name,
      cache_key,
      fn ->
        case Assets.download_asset(asset) do
          {:ok, binary} ->
            with {:ok, file_path} <- FileHandler.save_binary(binary, temp_file_path(asset.name)),
                 {:ok, extract_dir} <- ArchiveExtractor.extract(file_path, dest) do
              File.rm(file_path)
              wrap({:ok, extract_dir})
            else
              {:error, reason} -> wrap({:error, reason})
            end

          {:error, reason} ->
            wrap({:error, reason})
        end
      end,
      ttl: @cache_ttl
    )
    |> unwrap()
  end

  # Private functions

  @doc false
  @spec apply_filter([Asset.t()], keyword()) :: [Asset.t()]
  defp apply_filter(assets, opts) when is_list(assets) do
    assets
    |> filter_by_source(opts[:source])
    |> filter_by_language(opts[:lang])
    |> filter_by_archive_type(opts[:archive_type] || opts[:format])
  end

  @doc false
  @spec filter_by_source([Asset.t()], atom() | nil) :: [Asset.t()]
  defp filter_by_source(assets, nil), do: assets

  @doc false
  defp filter_by_source(assets, source) when is_atom(source) do
    Enum.filter(assets, fn %Asset{name: name} ->
      String.starts_with?(name, Atom.to_string(source))
    end)
  end

  @doc false
  @spec filter_by_language([Asset.t()], atom() | nil) :: [Asset.t()]
  defp filter_by_language(assets, nil), do: assets

  @doc false
  defp filter_by_language(assets, lang) when is_atom(lang) do
    all_langs = @languages ++ @eng_variants

    if Keyword.has_key?(all_langs, lang) do
      pattern = build_lang_pattern(lang)

      Enum.filter(assets, fn %Asset{name: name} ->
        Regex.match?(pattern, name)
      end)
    else
      []
    end
  end

  @doc false
  @spec filter_by_archive_type([Asset.t()], :tgz | :zip | nil) :: [Asset.t()]
  defp filter_by_archive_type(assets, nil), do: assets
  defp filter_by_archive_type(assets, type) when type not in [:tgz, :zip], do: assets

  defp filter_by_archive_type(assets, type) when type in [:tgz, :zip] do
    extension = if type == :tgz, do: ".tgz", else: ".zip"

    Enum.filter(assets, fn %Asset{name: name} ->
      String.ends_with?(name, extension)
    end)
  end

  @doc false
  defp build_lang_pattern(lang) do
    case lang do
      :eng -> ~r/(?<!common-)(eng)(?!-common)/
      :eng_common -> ~r/-eng-common/
      :all -> ~r/-all/
      _ -> ~r/-#{Regex.escape(Atom.to_string(lang))}-/
    end
  end

  defp infer_lang(string) do
    # Try to match one of the languages
    # if it matches, return the languages that it matches
    # if it doesn't match any, return an empty list
    cond do
      Regex.match?(~r/-eng-common/, string) ->
        :eng_common

      true ->
        # try to extract it from the -[lang]- pattern
        lang = Regex.scan(~r/-([a-z]+)-/, string)

        case lang do
          [[_, lang]] -> String.to_atom(lang)
          _ -> :unknown
        end
    end
  end

  defp infer_archive_format(string) do
    cond do
      Regex.match?(~r/.zip$/, string) -> :zip
      Regex.match?(~r/.tgz$/, string) -> :tgz
      true -> :unknown
    end
  end

  @doc false
  defp get_latest_assets do
    cache_key = :get_latest_assets

    Cachex.fetch(
      @cache_name,
      cache_key,
      fn ->
        Assets.get_latest_assets("prismify-co/jmdict-simplified")
        |> wrap()
      end,
      ttl: @cache_ttl
    )
    |> unwrap()
  end

  @doc false
  defp temp_file_path(filename) do
    Path.join(System.tmp_dir!(), filename)
  end
end
