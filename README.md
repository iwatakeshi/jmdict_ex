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

### JMdict

The origin of **JMdict** in the form of a JSON file is the repository [jmdict-simplified][jmdict-simplified].
In view of this, the said file is subject to the same license as its original source, namely **JMdict.xml**,
which is the intellectual property of the Electronic Dictionary Research and Development Group. 
See [EDRDG License][EDRDG-license]All derived files are distributed under the same license, as the original license requires it.

### Kanjidic
The Kanjidic data used in this project is derived from the [jmdict-simplified][jmdict-simplified] project, which converts the original XML to JSON. The original kanjidic2.xml file is released under the [Creative Commons Attribution-ShareAlike License v4.0][CC-BY-SA-4]. See the Copyright and Permissions section on the Kanjidic wiki for details.

### RADKFILE/KRADFILE

The RADKFILE and KRADFILE files are copyright and available under the [EDRDG Licence][EDRDG-license].
The copyright of the RADKFILE2 and KRADFILE2 files is held by Jim Rose.

[jmdict-simplified]: https://github.com/scriptin/jmdict-simplified
[EDRDG-license]: http://www.edrdg.org/edrdg/licence.html
[Apache-2.0]: http://www.apache.org/licenses/LICENSE-2.0
[CC-BY-SA-4]: http://creativecommons.org/licenses/by-sa/4.0