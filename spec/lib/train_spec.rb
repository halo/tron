require 'spec_helper'

RSpec.describe Tron::Failure, :included_tron do

  context 'chaining Success and Failure' do

    context 'using the #>> syntax' do
      it 'bails out on the first failure' do
        first  = ::Tron::Success.call :alright
        second = ::Tron::Failure.call :problem
        third  = ::Tron::Success.call :never
        expect(first.on_success { second }.on_success { third }).to be second
      end
    end

  end

end
