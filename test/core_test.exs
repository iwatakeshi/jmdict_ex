defmodule JMDictEx.Loaders.CoreTest do
  use ExUnit.Case
  alias JMDictEx.Loaders.Core

  setup do
    # Mock the Downloader and other dependencies
    :ok
  end

  test "load/4 with valid input" do
    # Mock the necessary functions and test load/4
    assert {:ok, _result} = Core.load(:jmdict, :eng, :zip, &JMDictEx.Decoders.JMDict.decode/1)
  end

  test "available_languages/1" do
    assert is_list(Core.available_languages(:jmdict))

    assert [] == Core.available_languages(:invalid)

  end

  test "valid_language?/2" do
    assert Core.valid_language?(:jmdict, :eng)
    refute Core.valid_language?(:jmdict, :invalid)
  end
end
