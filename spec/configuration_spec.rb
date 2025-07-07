require 'spec_helper'

describe Happi::Configuration do
  it { is_expected.to respond_to(:oauth_token) }
  it { is_expected.to respond_to(:host) }
  it { is_expected.to respond_to(:port) }
  it { is_expected.to respond_to(:timeout) }
  it { is_expected.to respond_to(:version) }
  it { is_expected.to respond_to(:use_json) }
  it { is_expected.to respond_to(:log_level) }
  it { is_expected.to respond_to(:token_type) }

  describe '.new' do
    context 'with options' do
      let(:config) { described_class.new(host: 'http://www.example.com', port: 80) }

      it 'overrides default values for options' do
        expect(config.host).to eq('http://www.example.com')
        expect(config.port).to eq(80)
      end
    end

    context 'without options' do
      let(:config) { described_class.new }

      it 'uses default values for options' do
        expect(config.host).to eq('http://localhost:8080')
        expect(config.port).to eq(443)
      end
    end
  end
end
