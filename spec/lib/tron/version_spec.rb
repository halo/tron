require 'spec_helper'

RSpec.describe Tron::VERSION do
  describe '::STRING' do
    it 'is the current version' do
      version = described_class::STRING

      expect(version).to eq '3.0.0'
    end
  end
end
