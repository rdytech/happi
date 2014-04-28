require 'spec_helper'

describe Happi::Client do

  describe 'options' do
    specify { expect(Happi::Client.new(host: 'http://www.google.com').host).to eql('http://www.google.com') }
    specify { expect(Happi::Client.new(port: 80).port).to eql(80) }
  end

  describe 'call' do

  end

  describe 'raise_error' do

  end
end
