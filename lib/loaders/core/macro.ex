# coveralls-ignore-start
defmodule JMDictEx.Loaders.Macro do
  @doc """
  A macro that defines loader functions based on the provided options.

  ## Options

    * `:source` - (required) The source of the data to be loaded.
    * `:decoder` - (required) The module used to decode the loaded data.
    * `:has_language` - (optional, default: true) Whether the loader should include language-specific functions.

  ## Generated Functions

  When `has_language` is true:

    * `load(lang, format \\\\ :zip)` - Loads data for the specified language and format.
    * `available_languages()` - Returns a list of available languages.

  When `has_language` is false:

    * `load(format \\\\ :zip)` - Loads data for the specified format.

  """
  defmacro __using__(opts) do
    source = Keyword.fetch!(opts, :source)
    decoder = Keyword.fetch!(opts, :decoder)
    has_language = Keyword.get(opts, :has_language, true)

    quote do
      alias JMDictEx.Loaders.Core, as: Loader

      if unquote(has_language) do
        @doc """
        Loads data for the specified language and format.

        ## Parameters

          * `lang` - The language of the data to be loaded.
          * `format` - The format of the data to be loaded (default: :zip).

        ## Examples

        iex> JMDictEx.Loaders.JMDict.load(:eng)
        {:ok, %JMDictEx.JMDict{...}}
        """
        def load(lang, format \\ :zip) when is_atom(lang) and is_atom(format) do
          Loader.load(unquote(source), lang, format, &unquote(decoder).decode/1)
        end

        @doc """
        Returns a list of available languages.
        """
        def available_languages, do: Loader.available_languages(unquote(source))
      else
        @doc """
        Loads data for the specified format.

        ## Parameters

          * `format` - The format of the data to be loaded (default: :zip).

        ## Examples

        iex> JMDictEx.Loaders.JMDict.load()
        {:ok, %JMDictEx.JMDict{...}}

        """
        def load(format \\ :zip) when is_atom(format) do
          Loader.load(unquote(source), nil, format, &unquote(decoder).decode/1)
        end
      end
    end
  end
end
# coveralls-ignore-stop
