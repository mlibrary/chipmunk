# frozen_string_literal: true

require "bagit"
require "file_errors"

class ChipmunkBag < BagIt::Bag

  class BagFile
    def initialize(path, type)
      @path = path
      @type = type
    end

    attr_reader :path, :type

    def exist?
      path.exist?
    end
  end

  def chipmunk_info_txt_file
    File.join bag_dir, "chipmunk-info.txt"
  end

  def chipmunk_info
    return {} unless File.exist?(chipmunk_info_txt_file)

    read_info_file chipmunk_info_txt_file
  end

  def data_dir
    Pathname.new(super)
  end

  def relative_data_files
    @relative_data_files ||= bag_files.map do |f|
      Pathname.new(f).relative_path_from(data_dir)
    end
  end

  # @param path [Pathname] Relative path to the file
  def include?(path)
    relative_data_files.include?(Pathname.new(path))
  end

  # Get a reference to a data file in the bag
  # @param path [Pathname] Relative path to the file
  def data_file(path)
    path = Pathname.new(path)
    if relative_data_files.include?(path)
      BagFile.new(data_dir/path, Rack::Mime.mime_type(path.extname))
    else
      raise FileNotFoundError, "No such file #{path} in bag"
    end
  end
end
