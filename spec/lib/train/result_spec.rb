require 'spec_helper'

RSpec.describe Train::Result do

  describe '#metadata' do
    it 'may be nil' do
      result = described_class.new(:the_code, nil)
      expect(result.code).to eq :the_code
      expect(result.metadata).to be_nil
    end
  end

  describe '#success?' do
    it 'is false' do
      expect(described_class.new).to_not be_success
    end
  end

  describe '#failure?' do
    it 'is false' do
      expect(described_class.new).to_not be_failure
    end
  end

  describe '#code' do
    it 'is a Symbol if possible' do
      expect(described_class.new(:normal).code).to eq :normal
      expect(described_class.new('normal').code).to eq :normal
      expect(described_class.new('it worked').code).to eq :'it worked'
      expect(described_class.new(0).code).to eq :'0'
      expect(described_class.new("\n").code).to eq :"\n"
    end

    it 'may be nil' do
      expect(described_class.new.code).to be_nil
      expect(described_class.new(nil).code).to be_nil
      expect(described_class.new('').code).to be_nil
    end
  end


end
