require 'spec_helper'
require 'rack/test'

describe Happi::File do
  context "with a file name" do
    subject { Happi::File.new(__FILE__) }

    describe '#initialize' do
      it 'assigns the correct attributes' do
        aggregate_failures do
          expect(subject.mime_type).to eq('application/x-ruby')
          expect(subject.file_name).to include('spec/file_spec.rb')
          expect(subject.original_filename).to be_nil
        end
      end
    end

    describe '#encode_file' do
      encoded = Base64.encode64(File.read(__FILE__))
      specify { expect(subject.encode_file).to eql(encoded) }
    end

    describe '#multipart' do
      specify { expect(subject.multipart).to be_an_instance_of(Faraday::UploadIO) }
      specify { expect(subject.multipart.content_type).to eq('application/x-ruby') }
      specify { expect(subject.multipart.original_filename).to eq('file_spec.rb') }
    end

    describe '#exists?' do
      specify { expect(subject.exists?).to eq(true) }
    end
  end

  context "with an ActionDispatch::Http::UploadedFile" do
    subject { Happi::File.new(Rack::Test::UploadedFile.new(__FILE__, 'application/x-ruby')) }

    describe '#initialize' do
      it 'assigns the correct attributes' do
        aggregate_failures do
          expect(subject.mime_type).to eq('application/x-ruby')
          expect(subject.file_name).not_to eq('file_spec.rb')
          expect(subject.original_filename).to eq('file_spec.rb')
        end
      end
    end

    describe '#encode_file' do
      encoded = Base64.encode64(File.read(__FILE__))
      specify { expect(subject.encode_file).to eql(encoded) }
    end

    describe '#multipart' do
      specify { expect(subject.multipart).to be_an_instance_of(Faraday::UploadIO) }
      specify { expect(subject.multipart.content_type).to eq('application/x-ruby') }
      specify { expect(subject.multipart.original_filename).to include('file_spec') }
    end

    describe '#exists?' do
      specify { expect(subject.exists?).to eq(true) }
    end
  end
end
