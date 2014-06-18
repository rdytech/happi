require 'spec_helper'
require 'rack/test'

describe Happi::File do
  context "with a file name" do
    subject { Happi::File.new(__FILE__) }

    describe '#encode_file' do
      encoded = Base64.encode64(File.read(__FILE__))
      specify { expect(subject.encode_file).to eql(encoded) }
    end

    describe '#mime_type' do
      specify { expect(subject.mime_type).to eql('application/x-ruby') }
    end

    describe '#multipart' do
      # specify { expect(subject.multipart).to }
    end

    describe '#exists?' do
      specify { expect(subject.exists?).to eq(true) }
    end
  end

  context "with an ActionDispatch::Http::UploadedFile" do
    subject { Happi::File.new(Rack::Test::UploadedFile.new(__FILE__, 'application/x-ruby')) }

    describe '#encode_file' do
      encoded = Base64.encode64(File.read(__FILE__))
      specify { expect(subject.encode_file).to eql(encoded) }
    end

    describe '#mime_type' do
      specify { expect(subject.mime_type).to eql('application/x-ruby') }
    end

    describe '#multipart' do
      # specify { expect(subject.multipart).to }
    end

    describe '#exists?' do
      specify { expect(subject.exists?).to eq(true) }
    end
  end
end
