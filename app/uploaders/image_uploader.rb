# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "static_images"
    #"uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Mimick an UploadedFile.
  class FilelessIO < StringIO
    attr_accessor :original_filename
    attr_accessor :content_type
  end

  # Param is a string of the format 'data:<CONTENT_TYPE eg image/gif>;base64,BASE64_ENCODED_IMAGE'
  def cache!(file)
    if file.match(%r{data:(.*);base64,(.*)})
      img_data = {
        :type =>      $1, # "image/png"
        :data_str =>  $2, # data string
        :extension => $1.split('/')[1] # "png"
      }
      local_file = FilelessIO.new(Base64.decode64(img_data[:data_str]))
      filename = "#{basename}.#{img_data[:extension]}"
      # this ensures unique filenames
      filename = "#{basename}.#{img_data[:extension]}" while model.class.unscoped.where(image: filename).count(:image) > 0
      local_file.original_filename = filename
      local_file.content_type = img_data[:type]
      super(local_file)
    end
  end

  def basename
    "#{model.title} #{model.category} #{model.activity}_#{Digest::MD5.hexdigest((Time.now.to_i / Time.now.nsec.to_f).to_s).last(5)}".parameterize
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
