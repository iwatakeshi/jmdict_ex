defmodule JMDictEx.Utils.ArchiveExtractorTest do
  use ExUnit.Case, async: true
  alias JMDictEx.Utils.ArchiveExtractor

  @temp_dir "test/fixtures/extractor"

  setup do
    File.mkdir_p!(@temp_dir)
    zip_file_path = create_zip_file()
    tgz_file_path = create_tgz_file()
    on_exit(fn -> File.rm_rf!(@temp_dir) end)
    %{zip_path: zip_file_path, tgz_path: tgz_file_path}
  end

  defp create_zip_file do
    zip_file_path = Path.join(@temp_dir, "test.zip")
    file1_path = Path.join(@temp_dir, "file1.txt")
    file2_path = Path.join(@temp_dir, "file2.txt")

    File.write!(file1_path, "Content of file 1")
    File.write!(file2_path, "Content of file 2")

    :zip.create(String.to_charlist(zip_file_path), [
      {~c"file1.txt", File.read!(file1_path)},
      {~c"file2.txt", File.read!(file2_path)}
    ])

    zip_file_path
  end

  defp create_tgz_file do
    tgz_file_path = Path.join(@temp_dir, "test.tgz")
    file1_path = Path.join(@temp_dir, "file1.txt")
    file2_path = Path.join(@temp_dir, "file2.txt")

    File.write!(file1_path, "Content of file 1")
    File.write!(file2_path, "Content of file 2")

    :erl_tar.create(
      String.to_charlist(tgz_file_path),
      [
        {~c"file1.txt", File.read!(file1_path)},
        {~c"file2.txt", File.read!(file2_path)}
      ],
      [:compressed]
    )

    tgz_file_path
  end

  describe "extract/2" do
    test "extracts a ZIP file successfully", %{zip_path: zip_path} do
      extract_dir = Path.join(@temp_dir, "extracted")
      assert {:ok, ^extract_dir} = ArchiveExtractor.extract(zip_path, extract_dir)
      assert File.exists?(Path.join(extract_dir, "file1.txt"))
      assert File.exists?(Path.join(extract_dir, "file2.txt"))
    end

    test "extracts a TGZ file successfully", %{tgz_path: tgz_path} do
      extract_dir = Path.join(@temp_dir, "extracted")
      assert {:ok, ^extract_dir} = ArchiveExtractor.extract(tgz_path, extract_dir)
      assert File.exists?(Path.join(extract_dir, "file1.txt"))
      assert File.exists?(Path.join(extract_dir, "file2.txt"))
    end

    test "returns an error for unknown archive type" do
      unknown_path = Path.join(@temp_dir, "test.unknown")
      File.touch!(unknown_path)
      assert {:error, "Unknown archive type"} = ArchiveExtractor.extract(unknown_path, @temp_dir)
    end

    test "returns an error for non-existent file" do
      non_existent_path = Path.join(@temp_dir, "non_existent.zip")
      assert {:error, _} = ArchiveExtractor.extract(non_existent_path, @temp_dir)
    end
  end
end
