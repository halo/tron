require 'spec_helper'

RSpec.describe Tron::Failure do

  describe '#on_success' do
    context 'passing in a proc' do
      it 'returns self' do
        instance = described_class.new
        expect(instance.on_success proc { :not_you }).to be instance
      end
    end

    context 'calling it with a block' do
      it 'calls the block and returns its instance' do
        instance = described_class.new
        expect(instance.on_success { :not_you }).to be instance
      end
    end

    context 'chaining it with #>>' do
      it 'does not go through the chain but returns the first result' do
        instance      = described_class.new
        first_result  = described_class.call(:first)
        second_result = described_class.call(:second)
        expect(instance.on_success { first_result }.on_success { second_result }).to be instance
      end
    end
  end

  describe '#on_failure' do
    context 'passing in a proc' do
      it 'calls the proc and returns its instance' do
        instance = described_class.new
        expect(instance.on_failure proc { :bingo }).to eq :bingo
      end
    end

    context 'calling it with a block' do
      it 'calls the block and returns its instance' do
        instance = described_class.new
        expect(instance.on_failure { :bingo }).to eq :bingo
      end
    end

    context 'chaining it with #>>' do
      it 'calls everyone in the chain and returns the last result' do
        instance      = described_class.new
        first_result  = described_class.call(:first)
        second_result = described_class.call(:second)
        expect(instance.on_failure { first_result }.on_failure { second_result }).to be second_result
      end
    end
  end

end
