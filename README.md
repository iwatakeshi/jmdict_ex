# JMDictEx

JMDictEx is an Elixir library for fetching, filtering, and downloading JMDict (Japanese-Multilingual Dictionary) and related dictionary files from the jmdict-simplified GitHub repository.

[![codecov](https://codecov.io/gh/iwatakeshi/jmdict_ex/graph/badge.svg?token=5XYXSI97PO)](https://codecov.io/gh/iwatakeshi/jmdict_ex)
[![Elixir CI](https://github.com/iwatakeshi/jmdict_ex/actions/workflows/elixir.yml/badge.svg)](https://github.com/iwatakeshi/jmdict_ex/actions/workflows/elixir.yml)
## Features

- Fetch the latest dictionary assets from the jmdict-simplified GitHub repository
- Filter assets by source type, language, and archive type
- Download and extract selected assets to a specified destination
- Support for various dictionary types (JMDict, JMnedict, Kanjidic2, etc.) and multiple languages

## Installation

The package can be installed by adding `jmdict_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jmdict_ex, git: "https://github.com/iwatakeshi/jmdict_ex.git", ref: "main" }
  ]
end
```

## Usage

Here are some basic usage examples:

```elixir
# Fetch all available assets
{:ok, assets} = JMDictEx.fetch_dicts([])

# Fetch JMDict assets for English
{:ok, eng_assets} = JMDictEx.fetch_dicts(source: :jmdict, lang: :eng)

# Download and extract an asset
{:ok, assets} = JMDictEx.fetch_dicts(source: :jmdict, lang: :eng)
JMDictEx.download_to(assets, "/path/to/destination")
# -> /path/to/destination/jmdict-eng-3.5.0+20240625144517.json

# Get available languages and source types
languages = JMDictEx.available_languages()
source_types = JMDictEx.available_source_types()
```

## Documentation

Detailed documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc). Once generated, the docs can be found in the `doc/` directory.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the [MIT License](LICENSE.md).
