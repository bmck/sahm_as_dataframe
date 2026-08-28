# Sahm As Dataframe

Calculate the Sahm recession indicator using FRED unemployment data, returning results as Polars dataframes.

This gem computes the Sahm indicator by fetching unemployment rate (UNRATE) data from the Federal Reserve Economic Data (FRED) API and applying the Sahm rule calculation.

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

**Requirements:** Ruby >= 3.3, polars-df 0.27.1

``` ruby
> SahmAsDataframe::Client.new.fetch
 => 
shape: (919, 4)                                                
┌────────────┬────────┬────────────────┬────────────────┐      
│ Timestamps ┆ UNRATE ┆ SAHM indicator ┆ SAHM recession │      
│ ---        ┆ ---    ┆ ---            ┆ ---            │      
│ date       ┆ f64    ┆ f64            ┆ bool           │      
╞════════════╪════════╪════════════════╪════════════════╡      
│ 1948-01-01 ┆ 3.4    ┆ 0.0            ┆ false          │      
│ 1948-02-01 ┆ 3.8    ┆ 0.2            ┆ false          │      
│ 1948-03-01 ┆ 4.0    ┆ 0.333333       ┆ false          │      
│ 1948-04-01 ┆ 3.9    ┆ 0.5            ┆ true           │      
│ 1948-05-01 ┆ 3.5    ┆ 0.4            ┆ false          │      
│ …          ┆ …      ┆ …              ┆ …              │      
│ 2024-03-01 ┆ 3.8    ┆ 0.4            ┆ false          │
│ 2024-04-01 ┆ 3.9    ┆ 0.366667       ┆ false          │
│ 2024-05-01 ┆ 4.0    ┆ 0.4            ┆ false          │
│ 2024-06-01 ┆ 4.1    ┆ 0.5            ┆ false          │
│ 2024-07-01 ┆ 4.3    ┆ 0.433333       ┆ false          │
└────────────┴────────┴────────────────┴────────────────┘ 
```

## Documentation

### The Sahm Rule

The Sahm rule is a recession indicator that signals the start of a recession when the three-month moving average of the national unemployment rate rises by 0.5 percentage points or more relative to its low during the previous 12 months.

This implementation calculates:
1. A 3-month rolling average of the unemployment rate
2. The minimum unemployment rate over the previous 12 months
3. The Sahm indicator as the difference between these two values
4. A recession flag when the indicator reaches or exceeds 0.5

### API Reference

The primary interface is `SahmAsDataframe::Client`:

```ruby
client = SahmAsDataframe::Client.new
df = client.fetch(start: '2020-01-01', fin: '2024-12-31', interval: '1d')
```

**Parameters:**
- `start` (optional): Start date for the data series (default: earliest available)
- `fin` (optional): End date for the data series (default: latest available)
- `interval` (optional): Data interval (default: '1d' for daily)

**Returns:**
A Polars DataFrame with columns:
- `Timestamps`: Date of observation
- `UNRATE`: Unemployment rate
- `SAHM indicator`: The calculated Sahm indicator value
- `SAHM recession`: Boolean flag indicating recession signal (indicator >= 0.5)

## Testing

This gem uses RSpec for testing. To run the test suite:

```bash
bundle install
bundle exec rake spec
```

Or simply:

```bash
bundle exec rake
```

The tests use stubbed data to avoid making live HTTP requests to the FRED API. All Sahm indicator calculations are verified against known test data to ensure accuracy of the rolling average and minimum calculations.

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
