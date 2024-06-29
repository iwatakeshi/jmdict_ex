defmodule JMDictExTest do
  use ExUnit.Case
  doctest JMDictEx

  alias JMDictEx.Models.Release.Asset

  @release_tag_name "3.5.0+20240625144517"
  @release_tag_name_encoded URI.encode(@release_tag_name)
  @jmdict_eng_file_name "jmdict-eng-#{@release_tag_name_encoded}.json.zip"
  @jmdict_spa_file_name "jmdict-spa-#{@release_tag_name_encoded}.json.zip"
  @jmdict_eng_zip_url "https://github.com/prismify-co/jmdict-simplified/releases/download/#{@release_tag_name_encoded}/jmdict-eng-#{@release_tag_name_encoded}.json.zip"
  @jmdict_spa_zip_url "https://github.com/prismify-co/jmdict-simplified/releases/download/#{@release_tag_name_encoded}/jmdict-spa-#{@release_tag_name_encoded}.json.zip"

  setup do
    test_output_dir = Path.join(System.tmp_dir!(), "jmdict_ex_test_#{:rand.uniform(1_000_000)}")
    File.mkdir_p!(test_output_dir)
    on_exit(fn -> File.rm_rf!(test_output_dir) end)
    {:ok, output_dir: test_output_dir}
  end

  describe "fetch_dicts/1" do
    test "fetches dictionaries with valid options" do
      assert {:ok, assets} = JMDictEx.fetch_dicts(source: :jmdict, lang: :eng, archive_type: :zip)
      assert is_list(assets)
      assert Enum.all?(assets, &match?(%Asset{}, &1))
    end

    test "returns empty list with invalid options" do
      assert {:ok, []} =
               JMDictEx.fetch_dicts(source: :invalid, lang: :invalid, archive_type: :invalid)
    end
  end

  describe "download_to/2" do
    test "downloads and extracts a single asset", %{output_dir: output_dir} do
      valid_asset = %Asset{
        name: @jmdict_eng_file_name,
        browser_download_url: @jmdict_eng_zip_url
      }

      test_dir = Path.join(output_dir, "single_asset_test")
      File.mkdir_p!(test_dir)

      assert {:ok, extracted_path} = JMDictEx.download_to(valid_asset, test_dir)

      expected_file = "jmdict-eng-3.5.0.json"
      full_path = Path.join(extracted_path, expected_file)

      assert File.exists?(full_path), "Expected file does not exist: #{full_path}"

      file_content = File.read!(full_path)
      assert String.starts_with?(file_content, "{"), "File content does not start with '{'"
      assert {:ok, _} = Jason.decode(file_content), "File content is not valid JSON"
    end

    test "handles download error for non-existent file", %{output_dir: output_dir} do
      bad_asset = %Asset{
        name: "nonexistent.zip",
        browser_download_url: "https://example.com/nonexistent.zip"
      }

      assert {:error, _reason} = JMDictEx.download_to(bad_asset, output_dir)
    end

    test "handles multiple asset downloads", %{output_dir: output_dir} do
      assets = [
        %Asset{
          name: @jmdict_eng_file_name,
          browser_download_url: @jmdict_eng_zip_url
        },
        %Asset{
          name: @jmdict_spa_file_name,
          browser_download_url: @jmdict_spa_zip_url
        }
      ]

      results = JMDictEx.download_to(assets, output_dir)
      assert length(results) == 2
      assert Enum.all?(results, &match?({:ok, _}, &1))
    end
  end

  test "available_languages/0 returns a list of available languages" do
    languages = JMDictEx.available_languages()
    assert is_list(languages)
    assert :eng in languages
    assert :all in languages
  end

  test "available_source_types/0 returns a list of available source types" do
    source_types = JMDictEx.available_source_types()
    assert is_list(source_types)
    assert :jmdict in source_types
    assert :kanjidic2 in source_types
  end
end
