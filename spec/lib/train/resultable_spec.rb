require 'spec_helper'

RSpec.shared_examples Train::Resultable do

  describe '#metadata' do
    it 'may be nil' do
      result = described_class.call(:the_code, nil)
      expect(result.code).to eq :the_code
      expect(result.metadata).to be_nil
    end

    it 'may be assigned something arbitrary' do
      object = Object.new
      expect(described_class.call(nil, object).metadata).to be object
    end
  end

  describe '#object' do
    it 'may be nil' do
      expect(described_class.new.object).to be_nil
    end

    it 'can be assigned via a metadata symbol' do
      expect(described_class.call(nil, object: 42).object).to eq 42
    end

    it 'can be assigned via a metadata string' do
      expect(described_class.call(nil, 'object' => 43).object).to eq 43
    end
  end

  describe '#code' do
    it 'is a Symbol if possible' do
      expect(described_class.call(:normal).code).to eq :normal
      expect(described_class.call('normal').code).to eq :normal
      expect(described_class.call('it worked').code).to eq :'it worked'
      expect(described_class.call(0).code).to eq :'0'
      expect(described_class.call("\n").code).to eq :"\n"
    end

    it 'may be nil' do
      expect(described_class.new.code).to be_nil
      expect(described_class.call(nil).code).to be_nil
      expect(described_class.call('').code).to be_nil
    end
  end

  describe '#meta' do
    it 'uses Hashie if available' do
      if defined?(::Hashie::Mash)
        expect(described_class.new.meta).to be_instance_of ::Hashie::Mash
        expect(described_class.call(nil, nil).meta).to be_instance_of ::Hashie::Mash
        expect(described_class.call(nil, {}).meta).to be_instance_of ::Hashie::Mash
        expect(described_class.call(nil, one: { two: :three }).meta.one.two).to eq :three
        expect(described_class.call(nil, []).meta).to eq []
        expect(described_class.call(nil, 'wow').meta).to eq 'wow'
      else
        expect(described_class.new.meta).to be_nil
        expect(described_class.call(nil, nil).meta).to be_nil
        expect(described_class.call(nil, {}).meta).to be_instance_of ::Hash
        expect(described_class.call(nil, one: { two: :three }).meta).to eq one: { two: :three }
        expect(described_class.call(nil, []).meta).to eq []
        expect(described_class.call(nil, 'wow').meta).to eq 'wow'
      end
    end
  end

end

RSpec.describe ::Train::Success do
  it_behaves_like Train::Resultable
end

RSpec.describe ::Train::Failure do
  it_behaves_like Train::Resultable
end
