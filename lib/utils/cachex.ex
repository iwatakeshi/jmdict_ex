defmodule JMDictEx.Utils.Cachex do
  @dialyzer {:nowarn_function, wrap_fn: 1}
  @doc """
  Wraps a value for Cachex.fetch, handling various return types.
  """
  def wrap(value) do
    case value do
      {:ok, result} -> {:commit, result}
      {:error, reason} -> {:ignore, reason}
      [] -> {:commit, []}
      nil -> {:ignore, nil}
      result -> {:commit, result}
    end
  end

  @doc """
  Unwraps a value from Cachex.fetch, returning the original format.
  If a default value is provided, it will be returned for {:ignore, _} cases.
  """
  def unwrap(cachex_result, default \\ nil)
  def unwrap({:commit, result}, _default), do: {:ok, result}
  def unwrap({:ignore, reason}, nil), do: {:error, reason}
  def unwrap({:ignore, _reason}, default), do: {:ok, default}
  def unwrap({:error, reason}, _default), do: {:error, reason}
  def unwrap({:ok, result}, _default), do: {:ok, result}
  def unwrap(result, _default), do: {:ok, result}

  @doc """
  Wraps a function result for Cachex.fetch.
  """
  def wrap_fn(fun) when is_function(fun, 0) do
    fun |> fun.() |> wrap()
  end

  @doc """
  Unwraps a Cachex.fetch result and applies a function to the value if it's a {:ok, result}.
  """
  def unwrap_and_apply(cachex_result, fun) when is_function(fun, 1) do
    case unwrap(cachex_result) do
      {:ok, result} -> fun.(result)
      other -> other
    end
  end
end
