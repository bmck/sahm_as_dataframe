# frozen_string_literal: true

require 'set'
require 'bundler/setup'
require_relative '../lib/sahm_as_dataframe'

failures = []
failures << 'version' if SahmAsDataframe::VERSION.to_s.empty?
client = SahmAsDataframe::Client.new
failures << 'instantiate' unless client.is_a?(SahmAsDataframe::Client)
failures << 'fetch' unless client.respond_to?(:fetch)
failures << 'unrate reader' unless client.unrate_reader.is_a?(FredAsDataframe::Client)

if failures.empty?
  puts 'test_client: ok'
else
  abort "test_client failed: #{failures.join(', ')}"
end
