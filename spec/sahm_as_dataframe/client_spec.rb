require 'spec_helper'
require 'polars-df'

RSpec.describe SahmAsDataframe::Client do
  describe '#fetch' do
    let(:client) { described_class.new }
    let(:mock_fred_client) { instance_double(FredAsDataframe::Client) }

    before do
      allow(FredAsDataframe::Client).to receive(:new).with('UNRATE').and_return(mock_fred_client)
    end

    context 'with known UNRATE data' do
      let(:test_data) do
        # Create 15 months of test data to properly test rolling calculations
        dates = (0..14).map { |i| Date.new(2024, 1, 1) + i * 30 }
        unrate_values = [
          3.5, 3.6, 3.7,  # Months 1-3: initial values
          3.4, 3.3, 3.2,  # Months 4-6: decreasing
          3.1, 3.0, 3.1,  # Months 7-9: minimum at month 8
          3.2, 3.3, 3.4,  # Months 10-12
          4.0, 4.2, 4.5   # Months 13-15: sharp increase
        ]
        
        Polars::DataFrame.new({
          'Timestamps' => dates,
          'UNRATE' => unrate_values
        })
      end

      before do
        allow(mock_fred_client).to receive(:fetch).and_return(test_data)
      end

      it 'returns a Polars DataFrame with the correct columns' do
        result = client.fetch
        expect(result).to be_a(Polars::DataFrame)
        expect(result.columns).to include('Timestamps', 'UNRATE', 'SAHM indicator', 'SAHM recession')
      end

      it 'computes the SAHM indicator using 3-month average minus 12-month minimum' do
        result = client.fetch
        
        # For month 13 (index 12, UNRATE = 4.0):
        # 3-month avg = (3.3 + 3.4 + 4.0) / 3 = 10.7 / 3 = 3.5666...
        # 12-month min = min(3.5, 3.6, 3.7, 3.4, 3.3, 3.2, 3.1, 3.0, 3.1, 3.2, 3.3, 3.4, 4.0) = 3.0
        # SAHM indicator = 3.5666... - 3.0 = 0.5666...
        sahm_month_13 = result.row(12, named: true)['SAHM indicator']
        expect(sahm_month_13).to be_within(0.01).of(0.57)

        # For month 15 (index 14, UNRATE = 4.5):
        # 3-month avg = (4.0 + 4.2 + 4.5) / 3 = 12.7 / 3 = 4.2333...
        # 12-month min = min(3.2, 3.1, 3.0, 3.1, 3.2, 3.3, 3.4, 4.0, 4.2, 4.5, ..., first 12 of rolling window) = 3.0
        # SAHM indicator = 4.2333... - 3.0 = 1.2333...
        sahm_month_15 = result.row(14, named: true)['SAHM indicator']
        expect(sahm_month_15).to be_within(0.01).of(1.23)
      end

      it 'flags recession when SAHM indicator >= 0.5' do
        result = client.fetch
        
        # Early months should not be flagged (low values)
        expect(result.row(2, named: true)['SAHM recession']).to be(false).or be_nil
        
        # Month 13 should be flagged (indicator ~0.87)
        expect(result.row(12, named: true)['SAHM recession']).to eq(true)
        
        # Month 15 should be flagged (indicator ~1.23)
        expect(result.row(14, named: true)['SAHM recession']).to eq(true)
      end

      it 'does not flag recession when SAHM indicator < 0.5' do
        result = client.fetch
        
        # Month 3 (index 2): 
        # 3-month avg = (3.5 + 3.6 + 3.7) / 3 = 3.6
        # 3-month min = min(3.5, 3.6, 3.7) = 3.5
        # SAHM = 3.6 - 3.5 = 0.1 < 0.5
        month_3_recession = result.row(2, named: true)['SAHM recession']
        expect([false, nil]).to include(month_3_recession)
      end

      it 'correctly handles the row_num intermediate column (should be dropped)' do
        result = client.fetch
        expect(result.columns).not_to include('row_num')
      end

      it 'correctly handles rolling calculation intermediate columns (should be dropped)' do
        result = client.fetch
        expect(result.columns).not_to include('3m rolling avg', '12m rolling_min')
      end

      it 'preserves the original UNRATE values' do
        result = client.fetch
        expect(result['UNRATE'].to_a).to eq(test_data['UNRATE'].to_a)
      end

      it 'accepts start, fin, and interval parameters' do
        expect(mock_fred_client).to receive(:fetch)
          .with(start: '2020-01-01', fin: '2024-12-31', interval: '1mo')
          .and_return(test_data)
        
        client.fetch(start: '2020-01-01', fin: '2024-12-31', interval: '1mo')
      end
    end

    context 'with a simple recession scenario' do
      let(:recession_data) do
        # Create a clear recession signal: unemployment jumps from 3.0 to 4.5
        dates = (0..14).map { |i| Date.new(2024, 1, 1) + i * 30 }
        unrate_values = [
          3.0, 3.0, 3.0, 3.0, 3.0, 3.0,  # Stable low unemployment
          3.0, 3.0, 3.0, 3.0, 3.0, 3.0,  # Continues stable
          4.5, 4.5, 4.5                   # Sharp jump
        ]
        
        Polars::DataFrame.new({
          'Timestamps' => dates,
          'UNRATE' => unrate_values
        })
      end

      before do
        allow(mock_fred_client).to receive(:fetch).and_return(recession_data)
      end

      it 'triggers recession flag when unemployment jumps significantly' do
        result = client.fetch
        
        # Month 13 (first 4.5 value):
        # 3-month avg = (3.0 + 3.0 + 4.5) / 3 = 3.5
        # 12-month min = min(3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 4.5) = 3.0
        # SAHM = 3.5 - 3.0 = 0.5 (exactly at threshold)
        month_13 = result.row(12, named: true)
        expect(month_13['SAHM indicator']).to be_within(0.01).of(0.5)
        expect(month_13['SAHM recession']).to eq(true)
        
        # Month 15 (third 4.5 value):
        # 3-month avg = (4.5 + 4.5 + 4.5) / 3 = 4.5
        # 12-month min = min(last 12 including current) = 3.0
        # SAHM = 4.5 - 3.0 = 1.5
        month_15 = result.row(14, named: true)
        expect(month_15['SAHM indicator']).to be_within(0.01).of(1.5)
        expect(month_15['SAHM recession']).to eq(true)
      end
    end
  end
end
