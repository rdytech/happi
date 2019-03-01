require 'mime/types'

class Happi::File
  attr_accessor :file_name
  attr_accessor :mime_type
  attr_accessor :original_filename

  def initialize(file)
    if file.is_a?(String)
      @mime_type = MIME::Types.type_for(file).first.content_type
      @file_name = file
    else
      @mime_type = file.content_type
      @file_name = file.path
      @original_filename =  file.original_filename
    end
  end

  def exists?
    File.exists?(file_name)
  end

  def multipart
    Faraday::UploadIO.new(file_name, mime_type, original_filename) if exists?
  end

  def encode_file
    Base64.encode64(File.read(file_name))
  end
end
