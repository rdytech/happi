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

  context "with a non-existent file" do
    subject { Happi::File.new('/path/to/non/existent/file.txt') }

    describe '#exists?' do
      it 'returns false' do
        expect(subject.exists?).to eq(false)
      end
    end

    describe '#multipart' do
      it 'returns nil when file does not exist' do
        expect(subject.multipart).to be_nil
      end
    end

    describe '#encode_file' do
      it 'raises an error when trying to encode non-existent file' do
        expect { subject.encode_file }.to raise_error(Errno::ENOENT)
      end
    end
  end

  context "with different file types" do
    let(:docx_file) { File.join(__dir__, 'fixtures', 'award.docx') }

    describe 'DOCX file' do
      subject { Happi::File.new(docx_file) }

      it 'detects correct MIME type' do
        expect(subject.mime_type).to eq('application/vnd.openxmlformats-officedocument.wordprocessingml.document')
      end

      it 'creates multipart for existing file' do
        multipart = subject.multipart
        expect(multipart).to be_an_instance_of(Faraday::UploadIO)
        expect(multipart.original_filename).to eq('award.docx')
      end
    end

    describe 'unrecognised extension' do
      # Characterisation test, not an endorsement: MIME::Types.type_for returns []
      # for an unknown extension, so #initialize calls content_type on nil instead
      # of falling back to a generic type.
      #
      # Pinned because it is the only mime-types behaviour this suite is sensitive
      # to - the asserted .rb and .docx mappings are identical from mime-types 2.4
      # through 3.7. If a mime-types-data release ever claims this extension, or the
      # nil is handled properly, this spec fails and says so.
      it 'raises rather than falling back to a generic type' do
        expect(MIME::Types.type_for('report.zzzunknown')).to be_empty
        expect { Happi::File.new('report.zzzunknown') }
          .to raise_error(NoMethodError, /content_type/)
      end
    end
  end
end
