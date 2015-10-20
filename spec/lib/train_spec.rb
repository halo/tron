require 'spec_helper'

RSpec.describe Train::Failure, :included_train do

  context 'chaining Success and Failure' do

    context 'using the #>> syntax' do
      it 'bails out on the first failure' do
        first  = ::Train::Success.call :alright
        second = ::Train::Failure.call :problem
        third  = ::Train::Success.call :never
        expect(first.on_success { second }.on_success { third }).to be second
      end
    end

  end

end
