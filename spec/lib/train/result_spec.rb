require 'spec_helper'

RSpec.describe Train::Result do

  describe '#metadata' do
    it 'may be nil' do
      result = described_class.new(:the_code, nil)
      expect(result.code).to eq :the_code
      expect(result.metadata).to be_nil
    end

    it 'may be assigned something arbitrary' do
      object = Object.new
      expect(described_class.new(nil, object).metadata).to be object
    end
  end

  describe '#object' do
    it 'may be nil' do
      expect(described_class.new.object).to be_nil
    end

    it 'can be assigned via a metadata symbol' do
      expect(described_class.new(nil, object: 42).object).to eq 42
    end

    it 'can be assigned via a metadata string' do
      expect(described_class.new(nil, 'object' => 43).object).to eq 43
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

  describe 'test setup' do
    it 'does not load the ::Hashie gem' do
      expect { ::Hashie }.to raise_error NameError
    end
  end

  describe '#meta' do
    it 'uses Hashie if available' do
      expect(described_class.new.meta).to be_nil
      expect(described_class.new(nil, nil).meta).to be_nil
      expect(described_class.new(nil, {}).meta).to be_instance_of ::Hash
      expect(described_class.new(nil, one: { two: :three }).meta).to eq one: { two: :three }
      expect(described_class.new(nil, []).meta).to eq []
      expect(described_class.new(nil, 'wow').meta).to eq 'wow'
      require 'hashie/mash'
      expect(described_class.new.meta).to be_instance_of ::Hashie::Mash
      expect(described_class.new(nil, nil).meta).to be_instance_of ::Hashie::Mash
      expect(described_class.new(nil, {}).meta).to be_instance_of ::Hashie::Mash
      expect(described_class.new(nil, one: { two: :three }).meta.one.two).to eq :three
      expect(described_class.new(nil, []).meta).to eq []
      expect(described_class.new(nil, 'wow').meta).to eq 'wow'
    end
  end

end
