require 'mime/types'

class Happi::File
  attr_accessor :file_name

  def initialize(file_name)
    @file_name = file_name
  end

  def exists?
    File.exists?(file_name)
  end

  def multipart
    Faraday::UploadIO.new(file_name, mime_type) if exists?
  end

  def mime_type
    MIME::Types.type_for(file_name).first.content_type
  end

  def encode_file
    Base64.encode64(File.read(file_name))
  end
end
