require 'spec_helper'

class DerivedClient < Happi::Client; end

describe Happi::Client do
  describe '.new' do
    let(:default_port) { Happi::Configuration.defaults[:port] }
    let(:class_level_port) { 80 }
    let(:instance_level_port) { 8080 }
    let(:derived_class_level_port) { 8081 }
    let(:config_port) { described_class.new.config.port }
    let(:derived_config_port) { DerivedClient.new.config.port }

    context 'with no supplied config' do
      it 'uses the default config for the base class' do
        expect(config_port).to eq(default_port)
      end

      it 'uses the default config for the derived class' do
        expect(derived_config_port).to eq(default_port)
      end
    end

    context 'with class level config for the base class' do
      before do
        described_class.configure { |config| config.port = class_level_port }
      end

      it 'overrides the default config for the base class' do
        expect(config_port).to eq(class_level_port)
      end

      it 'does not override the default config for the derived class' do
        expect(derived_config_port).to_not eq(class_level_port)
      end
    end

    context 'with class level config for the derived class' do
      before do
        DerivedClient.configure { |config| config.port = derived_class_level_port }
      end

      it 'does not affect the config for the base class' do
        expect(config_port).to_not eq(derived_class_level_port)
      end

      it 'overrides the default config for the derived class' do
        expect(derived_config_port).to eq(derived_class_level_port)
      end
    end

    context 'with instance level config for the base class' do
      before do
        described_class.configure { |config| config.port = class_level_port }
      end

      it 'overrides the class config for only that base class instance' do
        expect(Happi::Client.new(port: instance_level_port).config.port).to eq(instance_level_port)
        expect(config_port).to_not eq(instance_level_port)
      end

      it 'does not affect the config for an instance of the derived class' do
        expect(derived_config_port).to_not eq(instance_level_port)
      end
    end

    context 'with instance level config for the derived class' do
      before do
        described_class.configure { |config| config.port = class_level_port }
      end

      it 'does not affect the config for an instance of the base class' do
        expect(config_port).to_not eq(instance_level_port)
      end

      it 'overrides the class config for only that derived class instance' do
        expect(DerivedClient.new(port: instance_level_port).config.port).to eq(instance_level_port)
        expect(derived_config_port).to_not eq(instance_level_port)
      end
    end
  end

  describe '#connection_options' do
    subject { client.connection_options }

    context 'where config.token_type present' do
      let(:client) { described_class.new(token_type: 'bearer') }

      specify do
        expect(subject).to eq(token_type: 'bearer')
      end
    end

    context 'where config.token_type not present' do
      let(:client) { described_class.new }

      specify do
        expect(subject).to eq({})
      end
    end
  end
end
