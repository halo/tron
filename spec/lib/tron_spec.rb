require 'spec_helper'

RSpec.describe Tron do
  describe '.success' do
    context 'without arguments' do
      it 'raises an error' do
        expect do
          described_class.success
        end.to raise_error ArgumentError, /given 0, expected 1/
      end
    end

    context 'with one argument' do
      it 'is successful' do
        result = described_class.success :alright

        expect(result).to be_success
      end
    end

    context 'with metadata' do
      it 'is a struct' do
        result = described_class.success :alright

        expect(result).to be_a Struct
        #expect(result.to_s).to eq '#<Tron.success code=:alright>'
      end

      it 'is indifferent' do
        result = described_class.success :alright

        expect(result[:success]).to eq :alright
        expect(result['success']).to eq :alright
        expect(result[0]).to eq :alright
      end

      it 'has immutable attributes' do
        result = described_class.success 'alright'

        expect(result.success).to eq 'alright'
        expect(result.to_h).to eq success: 'alright'
        expect(result.members).to eq [:success]

        expect do
          result.success = 'no way'
        end.to raise_error NoMethodError

        expect do
          result[:success] = 'no way'
        end.to raise_error NoMethodError

        expect do
          result.success.upcase!
        end.to raise_error RuntimeError # FrozenError as of Ruby 2.5

        #expect(result.to_s).to eq '#<success success=:alright>'
        #expect(result.inspect).to eq '#<success code=:alright>'
      end
    end
  end

  context '' do
    it 'bails out on the first failure' do
      first  = described_class.success :alright
      second = described_class.failure :problem
      third  = described_class.success :never

      expect(first.on_success { second }.on_success { third }).to be second
    end
  end
end
