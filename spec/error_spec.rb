require 'spec_helper'

describe Happi::Error do
  describe '.new' do
    context 'with 1 argument' do
      let(:error) { Happi::Error.new('message') }
      specify { expect(error.message).to eq('message') }
      specify { expect(error.response).to be nil }
    end

    context 'with 2 arguments' do
      let(:error) { Happi::Error.new('message', 'response') }
      specify { expect(error.message).to eq('message') }
      specify { expect(error.response).to eq('response') }
    end
  end
end