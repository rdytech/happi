require 'spec_helper'

describe Happi::File do
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
    specify { expect(subject.exists?).to be_true }
  end
end
