defmodule JMDictEx do
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

  @source_types [:jmdict, :jmnedict, :kanjidic2, :kradfile, :radkfile]

  @doc """
  Returns a list of all available languages for dictionary assets.
  """
  def available_languages, do: Keyword.values(@languages ++ @eng_variants)

  @doc """
  Returns a list of all available source types for dictionary assets.
  """
  def available_source_types, do: @source_types

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
  @spec fetch_dicts(keyword()) :: {:ok, [Asset.t()]} | {:error, String.t()}
  def fetch_dicts(opts) when is_list(opts) do
    case get_latest_assets() do
      {:ok, assets} -> {:ok, apply_filter(assets, opts)}
      {:error, reason} -> {:error, reason}
    end
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
  def download_to({:ok, asset}, dest) when is_struct(asset, Asset), do: download_to(asset, dest)

  def download_to({:ok, assets}, dest) when is_list(assets),
    do: assets |> Enum.map(&download_to(&1, dest))

  def download_to({:error, reason}, _dest), do: {:error, reason}
  def download_to([%Asset{} = asset], dest), do: download_to(asset, dest)

  def download_to(assets, dest) when is_list(assets),
    do: assets |> Enum.map(&download_to(&1, dest))

  def download_to([], _dest), do: {:error, "No assets to download"}

  def download_to(%Asset{} = asset, dest) do
    with {:ok, binary} <- Assets.download_asset(asset),
         {:ok, file_path} <- FileHandler.save_binary(binary, temp_file_path(asset.name)),
         {:ok, extract_dir} <- ArchiveExtractor.extract(file_path, dest) do
      File.rm(file_path)
      {:ok, extract_dir}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  # Private functions

  @doc false
  @spec apply_filter([Asset.t()], keyword()) :: [Asset.t()]
  defp apply_filter(assets, opts) do
    assets
    |> filter_by_source(opts[:source])
    |> filter_by_lang(opts[:lang])
    |> filter_by_archive_type(opts[:archive_type])
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
  @spec filter_by_lang([Asset.t()], atom() | nil) :: [Asset.t()]
  defp filter_by_lang(assets, nil), do: assets

  @doc false
  defp filter_by_lang(assets, lang) when is_atom(lang) do
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

  @doc false
  defp get_latest_assets,
    do: Assets.get_latest_assets("prismify-co/jmdict-simplified")

  @doc false
  defp temp_file_path(filename) do
    Path.join(System.tmp_dir!(), filename)
  end
end
