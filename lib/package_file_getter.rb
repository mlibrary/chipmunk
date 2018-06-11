# frozen_string_literal: true

require "file_errors"

class PackageFileGetter
  def initialize(package, storage: Services.storage)
    raise "package must be stored" unless package.stored?
    @bag = storage.new(package.storage_location)
  end

  def files
    data_path = Pathname.new(bag.data_dir)
    bag.bag_files.map {|f| Pathname.new(f).relative_path_from(data_path) }
  end

  def sendfile(file)
    raise FileNotFoundError, "No such file #{file} in bag" unless files.include?(Pathname.new(file))

    [File.join(bag.data_dir, file),
     type: Rack::Mime.mime_type(File.extname(file))]
  end

  private

  attr_reader :bag
end
