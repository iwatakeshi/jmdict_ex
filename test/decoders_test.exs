defmodule JMDictEx.DecodersTest do
  use ExUnit.Case
  alias JMDictEx.Decoders.{JMDict, JMNEDict, KanjiDic2, Kradfile, Radkfile}

  test "JMDict.decode/1" do
    json = ~s({"words": [{"kana": [{}], "kanji": [{}], "sense": [{"gloss": [{}]}]}]})
    assert {:ok, %JMDictEx.Models.JMDict{}} = JMDict.decode(json)
  end

  test "JMNEDict.decode/1" do
    json = ~s({"words": [{"kana": [{}], "kanji": [{}], "translation": [{"translation": [{}]}]}]})
    assert {:ok, %JMDictEx.Models.JMNEDict{}} = JMNEDict.decode(json)
  end

  test "KanjiDic2.decode/1" do
    json =
      ~s({"characters": [{"codepoints": [{}], "dictionary_references": [{}], "misc": {"variants": [{}]}, "query_codes": [{}], "radicals": [{}], "reading_meaning": {"groups": [{"meanings": [{}], "readings": [{}]}]}}]})

    assert {:ok, %JMDictEx.Models.KanjiDic2{}} = KanjiDic2.decode(json)
  end

  test "Kradfile.decode/1" do
    json = ~s({"kanji": {"漢": ["a", "b", "c"]}})
    assert {:ok, %JMDictEx.Models.Kradfile{}} = Kradfile.decode(json)

    assert {:error, "Failed to decode Kradfile"} = Kradfile.decode(~s("kanji": []))
  end

  test "Radkfile.decode/1" do
    json = ~s({"radicals": {"1": {"code": "a", "kanji": ["漢"], "strokeCount": 1}}})
    assert {:ok, %JMDictEx.Models.Radkfile{}} = Radkfile.decode(json)

    assert {:error, "Failed to decode Radkfile"} = Radkfile.decode(~s("radicals": []))
  end
end
