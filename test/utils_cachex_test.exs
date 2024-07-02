defmodule JMDictEx.Utils.CachexTest do
  use ExUnit.Case
  alias JMDictEx.Utils.Cachex

  test "wrap/1 with empty list" do
    assert {:commit, []} = Cachex.wrap([])
  end

  test "wrap/1 with nil" do
    assert {:ignore, nil} = Cachex.wrap(nil)
  end

  test "unwrap/2 with default value" do
    assert {:ok, :default} = Cachex.unwrap({:ignore, :reason}, :default)
  end

  test "unwrap_and_apply/2" do
    result = {:commit, 10}
    fun = fn x -> x * 2 end
    assert 20 == Cachex.unwrap_and_apply(result, fun)
  end

  test "unwrap_and_apply/2 with error" do
    result = {:error, :reason}
    fun = fn x -> x * 2 end
    assert {:error, :reason} == Cachex.unwrap_and_apply(result, fun)
  end
end
