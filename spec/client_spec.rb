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

  describe '#connection' do
    let(:client) do
      DerivedClient.new(
        host: 'http://example.com',
        oauth_token: 'test_token'
      )
    end

    context 'Faraday 2.x compatibility' do
      it 'creates a Faraday connection without FaradayMiddleware errors' do
        expect { client.connection }.not_to raise_error
      end

      it 'returns a Faraday::Connection instance' do
        expect(client.connection).to be_a(Faraday::Connection)
      end

      it 'properly sets OAuth2 Authorization header' do
        connection = client.connection
        expect(connection.headers['Authorization']).to eq('Bearer test_token')
      end

      context 'with custom token_type' do
        let(:client) do
          DerivedClient.new(
            host: 'http://example.com',
            oauth_token: 'custom_token',
            token_type: 'bearer'
          )
        end

        it 'uses the specified token_type' do
          connection = client.connection
          expect(connection.headers['Authorization']).to eq('bearer custom_token')
        end
      end

      context 'without oauth_token' do
        let(:client) do
          DerivedClient.new(host: 'http://example.com')
        end

        it 'does not set Authorization header' do
          connection = client.connection
          expect(connection.headers['Authorization']).to be_nil
        end
      end

      context 'with use_json enabled' do
        let(:client) do
          DerivedClient.new(
            host: 'http://example.com',
            oauth_token: 'test_token',
            use_json: true
          )
        end

        it 'configures JSON request and response middleware' do
          connection = client.connection
          handlers = connection.builder.handlers.map(&:name)
          expect(handlers).to include('Faraday::Request::Json')
          expect(handlers).to include('Faraday::Response::Json')
        end
      end

      context 'with use_json disabled' do
        let(:client) do
          DerivedClient.new(
            host: 'http://example.com',
            oauth_token: 'test_token',
            use_json: false
          )
        end

        it 'configures multipart and url_encoded middleware' do
          connection = client.connection
          handlers = connection.builder.handlers.map(&:name)
          expect(handlers).to include('Faraday::Multipart::Middleware')
          expect(handlers).to include('Faraday::Request::UrlEncoded')
        end
      end
    end
  end

  describe '#url' do
    let(:client) { DerivedClient.new(host: 'http://example.com') }

    it 'constructs URL with api prefix and version' do
      expect(client.url('templates')).to eq('/api/v1/templates')
    end

    context 'with custom version' do
      let(:client) { DerivedClient.new(host: 'http://example.com', version: 'v2') }

      it 'uses the custom version' do
        expect(client.url('templates')).to eq('/api/v2/templates')
      end
    end
  end

  describe '#param_check' do
    let(:client) { DerivedClient.new(host: 'http://example.com') }

    it 'returns simple params unchanged' do
      params = { name: 'test', value: 123 }
      expect(client.param_check(params)).to eq(params)
    end

    it 'recursively processes nested hashes' do
      params = { outer: { inner: { deep: 'value' } } }
      result = client.param_check(params)
      expect(result[:outer][:inner][:deep]).to eq('value')
    end

    context 'with multipart objects' do
      let(:file) { Happi::File.new(__FILE__) }

      it 'converts objects with multipart method' do
        params = { file: file }
        result = client.param_check(params)
        expect(result[:file]).to be_a(Faraday::UploadIO)
      end

      it 'handles nested multipart objects' do
        params = { document: { attachment: file } }
        result = client.param_check(params)
        expect(result[:document][:attachment]).to be_a(Faraday::UploadIO)
      end
    end
  end

  describe '#logger' do
    let(:client) { DerivedClient.new(host: 'http://example.com') }

    it 'returns a logger instance' do
      expect(client.logger).to be_a(Logger)
    end

    it 'memoizes the logger' do
      logger1 = client.logger
      logger2 = client.logger
      expect(logger1).to equal(logger2)
    end
  end

  describe '#default_logger' do
    let(:client) { DerivedClient.new(host: 'http://example.com') }

    context 'when Rails is not defined' do
      it 'returns a Logger writing to STDOUT' do
        logger = client.default_logger
        expect(logger).to be_a(Logger)
      end
    end
  end

  describe '#errors' do
    let(:client) { DerivedClient.new(host: 'http://example.com') }

    it 'returns a hash of error mappings' do
      errors = client.errors
      expect(errors).to be_a(Hash)
      expect(errors[400]).to eq(Happi::Error::BadRequest)
      expect(errors[401]).to eq(Happi::Error::Unauthorized)
      expect(errors[404]).to eq(Happi::Error::NotFound)
      expect(errors[500]).to eq(Happi::Error::InternalServerError)
    end

    it 'memoizes the errors hash' do
      errors1 = client.errors
      errors2 = client.errors
      expect(errors1).to equal(errors2)
    end
  end

  describe 'HTTP methods with mocked responses' do
    let(:client) { DerivedClient.new(host: 'http://example.com', oauth_token: 'test') }
    let(:mock_response) do
      double('response',
        body: { 'result' => 'success' }.with_indifferent_access,
        status: 200
      )
    end
    let(:error_response) do
      double('response',
        body: { 'errors' => 'Something went wrong' },
        status: 400
      )
    end
    let(:connection) { double('connection') }

    before do
      allow(client).to receive(:connection).and_return(connection)
      allow(client).to receive(:logger).and_return(Logger.new(nil))
    end

    describe '#get' do
      it 'calls the connection with GET method' do
        expect(connection).to receive(:send).with(:get, '/api/v1/resource', {}).and_return(mock_response)
        result = client.get('resource')
        expect(result['result']).to eq('success')
      end

      it 'passes params to param_check' do
        expect(connection).to receive(:send).with(:get, '/api/v1/resource', { page: 1 }).and_return(mock_response)
        client.get('resource', page: 1)
      end
    end

    describe '#post' do
      it 'calls the connection with POST method' do
        expect(connection).to receive(:send).with(:post, '/api/v1/resource', { data: 'value' }).and_return(mock_response)
        result = client.post('resource', data: 'value')
        expect(result['result']).to eq('success')
      end
    end

    describe '#patch' do
      it 'calls the connection with PATCH method' do
        expect(connection).to receive(:send).with(:patch, '/api/v1/resource', { id: 1 }).and_return(mock_response)
        result = client.patch('resource', id: 1)
        expect(result['result']).to eq('success')
      end
    end

    describe '#delete' do
      it 'calls the connection with DELETE method' do
        expect(connection).to receive(:send).with(:delete, '/api/v1/resource', { id: 1 }).and_return(mock_response)
        result = client.delete('resource', id: 1)
        expect(result['result']).to eq('success')
      end
    end

    describe '#call' do
      context 'with successful response' do
        it 'returns the response' do
          expect(connection).to receive(:send).with(:get, '/api/v1/test', {}).and_return(mock_response)
          response = client.call(:get, '/api/v1/test', {})
          expect(response).to eq(mock_response)
        end
      end

      context 'with error response' do
        it 'raises an error for error status codes' do
          expect(connection).to receive(:send).with(:get, '/api/v1/test', {}).and_return(error_response)
          expect { client.call(:get, '/api/v1/test', {}) }.to raise_error(Happi::Error::BadRequest)
        end
      end

      context 'with debug logging' do
        before do
          client.config.log_level = :debug
          allow(client.logger).to receive(:debug)
          allow(client.logger).to receive(:info)
        end

        it 'logs with params when log_level is debug' do
          expect(client.logger).to receive(:debug).with(/Happi: GET.*test.*{}/)
          expect(connection).to receive(:send).with(:get, '/test', {}).and_return(mock_response)
          client.call(:get, '/test', {})
        end
      end

      context 'with info logging' do
        before do
          client.config.log_level = :info
          allow(client.logger).to receive(:info)
        end

        it 'logs without params when log_level is info' do
          expect(client.logger).to receive(:info).with(/Happi: GET.*test/)
          expect(connection).to receive(:send).with(:get, '/test', {}).and_return(mock_response)
          client.call(:get, '/test', {})
        end
      end
    end

    describe '#raise_error' do
      context 'with errors key in response body' do
        it 'raises error for 422 status' do
          response = double('response',
            body: { 'errors' => 'Validation failed' },
            status: 422
          )
          expect { client.raise_error(response) }.to raise_error(Happi::Error::UnprocessableEntity)
        end
      end

      context 'without errors key in response body' do
        it 'raises error for 404 status' do
          response = double('response',
            body: { 'message' => 'Not found' },
            status: 404
          )
          expect { client.raise_error(response) }.to raise_error(Happi::Error::NotFound)
        end
      end

      context 'for various HTTP status codes' do
        it 'raises BadRequest for 400' do
          response = double('response', body: {}, status: 400)
          expect { client.raise_error(response) }.to raise_error(Happi::Error::BadRequest)
        end

        it 'raises Unauthorized for 401' do
          response = double('response', body: {}, status: 401)
          expect { client.raise_error(response) }.to raise_error(Happi::Error::Unauthorized)
        end

        it 'raises Forbidden for 403' do
          response = double('response', body: {}, status: 403)
          expect { client.raise_error(response) }.to raise_error(Happi::Error::Forbidden)
        end

        it 'raises InternalServerError for 500' do
          response = double('response', body: {}, status: 500)
          expect { client.raise_error(response) }.to raise_error(Happi::Error::InternalServerError)
        end
      end
    end
  end
end
