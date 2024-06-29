defmodule JMDictEx.Utils.GitHub.Releases.Assets do
  @moduledoc """
  Module for interacting with GitHub releases and assets.

  This module provides functions to:
  - Download assets from GitHub releases
  - Fetch the latest release information
  - Retrieve assets from the latest release
  """

  alias Gitly.Parser
  alias JMDictEx.Models.Release
  alias JMDictEx.Models.Release.Asset
  alias JMDictEx.Models.Release.Author

  @type error :: {:error, String.t()}

  @doc """
  Downloads an asset from a GitHub release.

  ## Parameters

    * `asset` - An Asset struct containing the browser_download_url

  ## Returns

    * `{:ok, binary()}` - The downloaded asset as a binary
    * `{:error, String.t()}` - An error message if the download fails
  """
  @spec download_asset(Asset.t()) :: {:ok, binary()} | error()
  def download_asset(%Asset{browser_download_url: url}), do: download_asset(url, 0)

  @spec download_asset(String.t(), non_neg_integer()) :: {:ok, binary()} | error()
  defp download_asset(url, redirect_count) when is_binary(url) do
    if redirect_count >= 5 do
      {:error, "Too many redirects"}
    else
      case HTTPoison.get(url, [], follow_redirect: false) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, body}

        {:ok, %HTTPoison.Response{status_code: code, headers: headers}}
        when code in [301, 302, 303, 307, 308] ->
          case List.keyfind(headers, "Location", 0) do
            {"Location", location} ->
              download_asset(location, redirect_count + 1)

            # coveralls-ignore-next-line
            _ ->
              {:error, "Redirect location not found"}
          end

        {:ok, %HTTPoison.Response{status_code: status}} ->
          {:error, "Failed to download asset. Status code: #{status}"}

        # coveralls-ignore-next-line
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "Failed to download asset: #{inspect(reason)}"}
      end
    end
  end

  @doc """
  Retrieves the assets from the latest release of a GitHub repository.

  ## Parameters

    * `input` - A string in the format "owner/repo"

  ## Returns

    * `{:ok, [Asset.t()]}` - A list of Asset structs from the latest release
    * `{:error, String.t()}` - An error message if the retrieval fails
  """
  @spec get_latest_assets(String.t()) :: {:ok, [Asset.t()]} | error()
  def get_latest_assets(input) do
    case get_latest_release(input) do
      {:ok, %Release{assets: assets}} ->
        {:ok, assets}

      # coveralls-ignore-next-line
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Retrieves the latest release information for a GitHub repository.

  ## Parameters

    * `input` - A string in the format "owner/repo"

  ## Returns

    * `{:ok, Release.t()}` - A Release struct containing the latest release information
    * `{:error, String.t()}` - An error message if the retrieval fails
  """
  @spec get_latest_release(String.t()) :: {:ok, Release.t()} | error()
  def get_latest_release(input) do
    with {:ok, result} <- Parser.parse(input),
         {:ok, url} <- build_latest_url(result),
         {:ok, body} <- fetch_release(url),
         {:ok, release} <- decode_release(body) do
      {:ok, release}
    else
      # coveralls-ignore-next-line
      {:error, reason} -> {:error, reason}
    end
  end

  @spec build_latest_url(map()) :: {:ok, String.t()} | error()
  defp build_latest_url(%{owner: owner, repo: repo}) do
    {:ok, "https://api.github.com/repos/#{owner}/#{repo}/releases/latest"}
  end

  @spec fetch_release(String.t()) :: {:ok, String.t()} | error()
  defp fetch_release(url) do
    headers = [{"User-Agent", "jmdict-elixir"}]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      # coveralls-ignore-start
      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:error, "Unexpected status code: #{status}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to fetch latest release: #{inspect(reason)}"}
        # coveralls-ignore-stop
    end
  end

  @spec decode_release(String.t()) :: {:ok, Release.t()} | error()
  defp decode_release(body) do
    case Poison.decode(body, as: %Release{assets: [%Asset{}], author: %Author{}}) do
      {:ok, release} -> {:ok, release}
      # coveralls-ignore-next-line
      {:error, _} -> {:error, "Failed to decode release data"}
    end
  end
end
