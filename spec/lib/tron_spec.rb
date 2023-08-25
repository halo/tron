# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'

RSpec.describe Tron do
  describe '.success' do
    context 'without code' do
      it 'raises an error' do
        expect do
          described_class.success
        end.to raise_error ArgumentError, /given 0, expected 1/
      end
    end

    context 'with a non-symbolic code' do
      it 'raises an error' do
        expect do
          described_class.success nil
        end.to raise_error ArgumentError, 'Tron.success must be called with a Symbol as first argument'

        expect do
          described_class.success 42
        end.to raise_error ArgumentError, 'Tron.success must be called with a Symbol as first argument'
      end
    end

    context 'with non-hash-like attributes' do
      it 'raises an error' do
        expect do
          described_class.success :bad, OpenStruct.new(values: :exists)
        end.to raise_error ArgumentError, 'The second argument (metadata) for Tron.success must respond to #keys'

        expect do
          described_class.success :bad, OpenStruct.new(keys: :exists)
        end.to raise_error ArgumentError, 'The second argument (metadata) for Tron.success must respond to #values'
      end
    end

    context 'with only the code as argument' do
      it 'is successful and assigns the success code' do
        result = described_class.success :alright

        expect(result).to be_success
        expect(result.success).to eq :alright
        expect(result.failure).to be nil
      end
    end

    context 'with code and attributes' do
      it 'is an anonymous data' do
        result = described_class.success :alright

        expect(result).to be_a Data
        expect(result.to_h).to eq success: :alright
        expect(result.members).to eq [:success]
      end

      it 'has immutable attributes' do
        result = described_class.success :alright, space_ship: 'Enterprise'

        expect do
          result.space_ship = 'this should not work'
        end.to raise_error NoMethodError

        expect do
          result[:space_ship] = 'this should not work'
        end.to raise_error NoMethodError

        expect do
          result.space_ship.upcase!
        end.to raise_error RuntimeError # FrozenError as of Ruby 2.5
      end
    end

    context 'when the attributes contain a :failure key' do
      it 'does not make the instance a failure' do
        result = described_class.success :alright, failure: :i_actually_meant_failure

        expect(result).to be_success
        expect(result).not_to be_failure
        expect(result.success).to be :alright
        expect(result.failure).to be nil
      end
    end

    context 'when the attributes contain a "failure" key' do
      it 'does not make the instance a failure' do
        result = described_class.success :alright, 'failure' => :i_actually_meant_failure

        expect(result).to be_success
        expect(result).not_to be_failure
        expect(result.success).to be :alright
        expect(result.failure).to be nil
      end
    end

    context 'when the attributes contain a :success key' do
      it 'raises an error' do
        expect do
          described_class.success :alright, success: :more_alright
        end.to raise_error ArgumentError, /duplicate/
      end
    end
  end

  describe 'Data#on_success' do
    context 'with a proc' do
      it 'calls the proc and returns its instance' do
        instance = described_class.success(:ok)
        result = instance.on_success(proc { :bingo })

        expect(result).to eq :bingo
      end

      it 'yields its result' do
        instance = described_class.success(:ok)
        result = nil
        instance.on_success(proc { |thing| result = thing })

        expect(result).to be instance
      end
    end

    context 'when calling it with a block' do
      it 'calls the block and returns its instance' do
        instance = described_class.success(:ok)
        result = instance.on_success { :bingo }

        expect(result).to eq :bingo
      end

      it 'yields its result' do
        instance = described_class.success(:ok)
        result = nil
        instance.on_success { |thing| result = thing }

        expect(result).to be instance
      end
    end

    context 'when chaining' do
      it 'calls everyone in the chain and returns the last result' do
        first  = described_class.success :way
        second = described_class.success :to
        third  = described_class.success :go

        result = first.on_success { second }
                      .on_success { third }
                      .on_success { :done }

        expect(result).to eq :done
      end

      it 'bails out on the first failure' do
        first  = described_class.success :alright
        second = described_class.failure :problem
        third  = described_class.success :never

        result = first.on_success { second }
                      .on_success { third }

        expect(result).to be second
      end
    end
  end

  describe '.failure' do
    context 'without code' do
      it 'raises an error' do
        expect do
          described_class.failure
        end.to raise_error ArgumentError, /given 0, expected 1/
      end
    end

    context 'with a non-symbolic code' do
      it 'raises an error' do
        expect do
          described_class.failure nil
        end.to raise_error ArgumentError, 'Tron.failure must be called with a Symbol as first argument'

        expect do
          described_class.failure 42
        end.to raise_error ArgumentError, 'Tron.failure must be called with a Symbol as first argument'
      end
    end

    context 'with non-hash-like attributes' do
      it 'raises an error' do
        expect do
          described_class.failure :bad, OpenStruct.new(values: :exists)
        end.to raise_error ArgumentError, 'The second argument (metadata) for Tron.failure must respond to #keys'

        expect do
          described_class.failure :bad, OpenStruct.new(keys: :exists)
        end.to raise_error ArgumentError, 'The second argument (metadata) for Tron.failure must respond to #values'
      end
    end

    context 'with only the code as argument' do
      it 'is failureful and assigns the failure code' do
        result = described_class.failure :too_bad

        expect(result).to be_failure
        expect(result.failure).to eq :too_bad
        expect(result.success).to be nil
      end
    end

    context 'with code and attributes' do
      it 'is an anonymous data' do
        result = described_class.failure :too_bad

        expect(result).to be_a Data
        expect(result.to_h).to eq failure: :too_bad
        expect(result.members).to eq [:failure]
      end

      it 'has immutable attributes' do
        result = described_class.failure :too_bad, space_ship: 'Enterprise'

        expect do
          result.space_ship = 'this should not work'
        end.to raise_error NoMethodError

        expect do
          result[:space_ship] = 'this should not work'
        end.to raise_error NoMethodError

        expect do
          result.space_ship.upcase!
        end.to raise_error RuntimeError # FrozenError as of Ruby 2.5
      end
    end

    context 'when the attributes contain a :success key' do
      it 'does not make the instance a success' do
        result = described_class.failure :alright, success: :i_actually_meant_success

        expect(result).to be_failure
        expect(result).not_to be_success
        expect(result.failure).to be :alright
        expect(result.success).to be nil
      end
    end

    context 'when the attributes contain a "success" key' do
      it 'does not make the instance a success' do
        result = described_class.failure :alright, 'success' => :i_actually_meant_success

        expect(result).to be_failure
        expect(result).not_to be_success
        expect(result.failure).to be :alright
        expect(result.success).to be nil
      end
    end

    context 'when the attributes contain a :failure key' do
      it 'raises an error' do
        expect do
          described_class.failure :alright, failure: :more_alright
        end.to raise_error ArgumentError, /duplicate/
      end
    end
  end

  describe 'Data#on_failure' do
    context 'with a proc' do
      it 'calls the proc and returns its instance' do
        instance = described_class.failure(:oh_no)
        result = instance.on_failure(proc { :boom })

        expect(result).to eq :boom
      end

      it 'yields its result' do
        instance = described_class.failure(:oh_no)
        result = nil
        instance.on_failure(proc { |thing| result = thing })

        expect(result).to be instance
      end
    end

    context 'when calling it with a block' do
      it 'calls the block and returns its instance' do
        instance = described_class.failure(:too_bad)
        result = instance.on_failure { :bingo }

        expect(result).to eq :bingo
      end

      it 'yields its result' do
        instance = described_class.failure(:too_bad)
        result = nil
        instance.on_failure { |thing| result = thing }

        expect(result).to be instance
      end
    end

    context 'when chaining' do
      it 'calls everyone in the chain and returns the last result' do
        first  = described_class.failure :way
        second = described_class.failure :to
        third  = described_class.failure :go

        result = first.on_failure { second }
                      .on_failure { third }
                      .on_failure { :done }

        expect(result).to eq :done
      end

      it 'bails out on the first success' do
        first  = described_class.failure :too_bad
        second = described_class.success :problem
        third  = described_class.failure :never

        result = first.on_failure { second }
                      .on_failure { third }

        expect(result).to be second
      end
    end
  end

  describe '.some_attribute' do
    context 'accessing an unknown attribute' do
      it 'raises an informative error' do
        instance = described_class.success :ok

        expect do
          instance.not_the_attribute_youre_looking_for
        end.to raise_error NoMethodError, /#<data success=:ok>/
      end
    end
  end
end
