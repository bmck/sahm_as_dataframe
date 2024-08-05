# EconDataReader

Up to date remote economic data access for ruby, using Polars dataframes. 

This package will fetch economic and financial information from several different sources.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sahm_as_dataframe'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install sahm_as_dataframe


### Configuration

This gem does not require configuration on its own, but it does require the fred_as_dataframe gem, which does require an API key from the Federal Reserve Economic Database.  See that gem's homepage for details on its configuration.

## Usage

``` ruby
EconDataReader::SahmAsDataframe.new('IEXE0102').fetch

EconDataReader::Fred.new('GS10').fetch 

EconDataReader::Bls.new('LNS14000006')

EconDataReader::Nasdaq.new('WIKI/AAPL').fetch
```

## Documentation

TBD

## Contributing

Others are welcome to contribute to the project.

The following conventions are intended for this project.
 * Different sources are intended to reside in different classes.  
 * API keys (if needed) should be able to be set in the single configuration file.  
 * Series should be able to be identified via a single unique string, provided in the constructor.
 * When fetched, the dataset may be filtered based on optional (hash) arguments.
 * Output should be provided in a consistent DataFrame format (currently Polars::DataFrame).

Bug reports and pull requests are welcome on GitHub at https://github.com/bmck/sahm_as_dataframe.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
