require 'spec_helper'

describe Happi::Configuration do
  describe 'options' do
    specify { expect(Happi::Configuration.new(host: 'http://www.google.com').host).to eql('http://www.google.com') }
    specify { expect(Happi::Configuration.new(port: 80).port).to eql(80) }

    specify do
      Happi::Client.configure { |config| config.host = 'http://localhost:3000' }
      expect(Happi::Client.config.host).to eq 'http://localhost:3000'
    end
  end
end
