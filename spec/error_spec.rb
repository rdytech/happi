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

    context 'with no arguments' do
      let(:error) { Happi::Error.new }
      specify { expect(error.message).to eq('Happi::Error') }
      specify { expect(error.response).to be nil }
    end
  end

  describe 'inheritance' do
    it 'is a StandardError' do
      expect(Happi::Error.new).to be_a(StandardError)
    end

    it 'can be rescued as StandardError' do
      expect { raise Happi::Error }.to raise_error(StandardError)
    end
  end

  describe Happi::Error::ClientError do
    describe '#message' do
      it 'returns default client error message' do
        error = Happi::Error::ClientError.new
        expect(error.message).to eq('A client error occurred')
      end
    end

    it 'inherits from Happi::Error' do
      expect(Happi::Error::ClientError.new).to be_a(Happi::Error)
    end

    it 'stores response when provided' do
      response = double('response')
      error = Happi::Error::ClientError.new('test', response)
      expect(error.response).to eq(response)
    end
  end

  describe Happi::Error::BadRequest do
    it 'inherits from ClientError' do
      expect(Happi::Error::BadRequest.new).to be_a(Happi::Error::ClientError)
    end

    it 'returns specific error message' do
      error = Happi::Error::BadRequest.new
      expect(error.message).to eq('The request was incorrectly performed')
    end
  end

  describe Happi::Error::Unauthorized do
    it 'inherits from ClientError' do
      expect(Happi::Error::Unauthorized.new).to be_a(Happi::Error::ClientError)
    end

    it 'returns specific error message' do
      error = Happi::Error::Unauthorized.new
      expect(error.message).to eq('The request was not authorized')
    end
  end

  describe Happi::Error::Forbidden do
    it 'inherits from ClientError' do
      expect(Happi::Error::Forbidden.new).to be_a(Happi::Error::ClientError)
    end

    it 'returns specific error message' do
      error = Happi::Error::Forbidden.new
      expect(error.message).to eq('The request was denied')
    end
  end

  describe Happi::Error::NotFound do
    it 'inherits from ClientError' do
      expect(Happi::Error::NotFound.new).to be_a(Happi::Error::ClientError)
    end

    it 'returns specific error message' do
      error = Happi::Error::NotFound.new
      expect(error.message).to eq('The requested resource was not found')
    end
  end

  describe Happi::Error::NotAcceptable do
    it 'inherits from ClientError' do
      expect(Happi::Error::NotAcceptable.new).to be_a(Happi::Error::ClientError)
    end

    it 'returns specific error message' do
      error = Happi::Error::NotAcceptable.new
      expect(error.message).to eq('The requested format was not accepted')
    end
  end

  describe Happi::Error::RequestTimeout do
    it 'inherits from ClientError' do
      expect(Happi::Error::RequestTimeout.new).to be_a(Happi::Error::ClientError)
    end

    it 'returns specific error message' do
      error = Happi::Error::RequestTimeout.new
      expect(error.message).to eq('The request timed out')
    end
  end

  describe Happi::Error::UnprocessableEntity do
    it 'inherits from ClientError' do
      expect(Happi::Error::UnprocessableEntity.new).to be_a(Happi::Error::ClientError)
    end

    it 'returns specific error message' do
      error = Happi::Error::UnprocessableEntity.new
      expect(error.message).to eq('The request was not able to be processed')
    end
  end

  describe Happi::Error::ServerError do
    describe '#message' do
      it 'returns default server error message' do
        error = Happi::Error::ServerError.new
        expect(error.message).to eq('A server error occurred')
      end
    end

    it 'inherits from Happi::Error' do
      expect(Happi::Error::ServerError.new).to be_a(Happi::Error)
    end

    it 'stores response when provided' do
      response = double('response')
      error = Happi::Error::ServerError.new('test', response)
      expect(error.response).to eq(response)
    end
  end

  describe Happi::Error::InternalServerError do
    it 'inherits from ServerError' do
      expect(Happi::Error::InternalServerError.new).to be_a(Happi::Error::ServerError)
    end

    it 'uses ServerError message' do
      error = Happi::Error::InternalServerError.new
      expect(error.message).to eq('A server error occurred')
    end
  end

  describe Happi::Error::BadGateway do
    it 'inherits from ServerError' do
      expect(Happi::Error::BadGateway.new).to be_a(Happi::Error::ServerError)
    end

    it 'uses ServerError message' do
      error = Happi::Error::BadGateway.new
      expect(error.message).to eq('A server error occurred')
    end
  end

  describe Happi::Error::TooManyRequests do
    it 'inherits from ServerError' do
      expect(Happi::Error::TooManyRequests.new).to be_a(Happi::Error::ServerError)
    end

    it 'uses ServerError message' do
      error = Happi::Error::TooManyRequests.new
      expect(error.message).to eq('A server error occurred')
    end
  end

  describe Happi::Error::ServiceUnavailable do
    it 'inherits from ServerError' do
      expect(Happi::Error::ServiceUnavailable.new).to be_a(Happi::Error::ServerError)
    end

    it 'uses ServerError message' do
      error = Happi::Error::ServiceUnavailable.new
      expect(error.message).to eq('A server error occurred')
    end
  end

  describe Happi::Error::GatewayTimeout do
    it 'inherits from ServerError' do
      expect(Happi::Error::GatewayTimeout.new).to be_a(Happi::Error::ServerError)
    end

    it 'uses ServerError message' do
      error = Happi::Error::GatewayTimeout.new
      expect(error.message).to eq('A server error occurred')
    end
  end

  describe 'error hierarchy' do
    context 'client errors' do
      let(:client_errors) do
        [
          Happi::Error::BadRequest,
          Happi::Error::Unauthorized,
          Happi::Error::Forbidden,
          Happi::Error::NotFound,
          Happi::Error::NotAcceptable,
          Happi::Error::RequestTimeout,
          Happi::Error::UnprocessableEntity
        ]
      end

      it 'all inherit from ClientError' do
        client_errors.each do |error_class|
          expect(error_class.new).to be_a(Happi::Error::ClientError)
        end
      end

      it 'all inherit from Happi::Error' do
        client_errors.each do |error_class|
          expect(error_class.new).to be_a(Happi::Error)
        end
      end
    end

    context 'server errors' do
      let(:server_errors) do
        [
          Happi::Error::InternalServerError,
          Happi::Error::BadGateway,
          Happi::Error::TooManyRequests,
          Happi::Error::ServiceUnavailable,
          Happi::Error::GatewayTimeout
        ]
      end

      it 'all inherit from ServerError' do
        server_errors.each do |error_class|
          expect(error_class.new).to be_a(Happi::Error::ServerError)
        end
      end

      it 'all inherit from Happi::Error' do
        server_errors.each do |error_class|
          expect(error_class.new).to be_a(Happi::Error)
        end
      end
    end
  end

  describe 'response attribute' do
    let(:mock_response) { double('response', status: 404, body: { error: 'Not found' }) }

    it 'is accessible on all error types' do
      [
        Happi::Error,
        Happi::Error::ClientError,
        Happi::Error::ServerError,
        Happi::Error::NotFound,
        Happi::Error::InternalServerError
      ].each do |error_class|
        error = error_class.new('test message', mock_response)
        expect(error.response).to eq(mock_response)
      end
    end
  end
end