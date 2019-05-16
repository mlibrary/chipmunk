# frozen_string_literal: true

require "bagit"
require "pathname"
require "semantic_logger"
require "chipmunk/package/null_storage"
require "chipmunk/errors"

module Chipmunk
  class Bag
    include SemanticLogger::Loggable

    # The package ID
    attr_reader :id

    # TODO: Decide how much a Chipmunk::Bag needs to access the storage/disk itself or
    #       if the BagIt::Bag bound to somewhere under the storage root is enough.
    # TODO: Reconcile the notions of Bags _inside_ the repository and _outside_ of it.
    #       Notably, the storage and repository are separate. We could potentially
    #       use read-only storage for items located by the repository and expose
    #       explicit or transactional operations for updates. We could also use
    #       less strict storage for in-flight packages. These are all draft thoughts
    #       seeking to clarify the role of Chipmunk::Bag -- does it have unmetered
    #       access to disk? There are parallel questions on the Package model.
    def initialize(id:, bag:)
      @id = id
      @bag = bag
    end

    # @deprecated This is a transitional method to move away from BagRepository
    #   while determining the appropriate interface for Repository#find and
    #   Storage#get. We should not have any dependencies on Rails models here,
    #   relying strictly on value objects. This also disregards the configured
    #   bag_storage entirely because packages currently hold their own
    #   stored_location in absolute form.
    def self.__from_package__(package)
      logger.debug "[DEPRECATION] Bag::__from_package__ called from #{caller(1..1).first}"
      raise Chipmunk::BagNotFoundError unless package.stored?
      new(id: package.bag_id, bag: BagIt::Bag.new(package.storage_location))
    end

    # Copy the file at {path} within the Bag to {dst}, using IO::copy_stream.
    #
    # @param path [Pathname|String] the relative path to the file to copy from
    # @param destination [String|IO] the filename or IO object for writing to
    def copy_stream(path, destination)
      raise FileNotFoundError, "File not found in bag: #{path}" unless includes?(path)
      IO.copy_stream((bag_dir/path).to_s, destination)
    end

    def valid?
      bag.valid?
    end

    def chipmunk_info
      return {} unless File.exist?(chipmunk_info_txt_file)

      bag.send(:read_info_file, chipmunk_info_txt_file)
    end

    # Get the paths of all files relative to the root of the bag
    # @see {#bag_dir}
    def relative_files
      files.map {|f| f.relative_path_from(bag_dir) }
    end

    # Get the paths of the data files relative to the data directory
    # @see {#data_dir}
    def relative_data_files
      data_files.map {|f| f.relative_path_from(data_dir) }
    end

    # Test if the bag contains a data file
    # @param path [Pathname|String] Path of the file relative to the data directory
    # @see {#data_dir}
    def includes_data?(path)
      relative_data_files.include?(Pathname.new(path))
    end

    # Test if the bag contains a path
    # @param path [Pathname|String] Path to the file relative to the bag root.
    # @see {#bag_dir}
    def includes?(path)
      relative_files.include?(Pathname.new(path))
    end

    def tag_files
      bag.tag_files.map {|f| Pathname(f).relative_path_from(bag_dir) }
    end

    # Get a reference to a data file in the bag
    # @param path [Pathname] Relative path to the file
    def data_file!(path)
      path = Pathname.new(path)
      if relative_data_files.include?(path)
        data_dir/path
      else
        raise FileNotFoundError, "No such file #{path} in bag"
      end
    end

    def copy(destination)
      destination.write(bag_dir, relative_files)
    end

    private

    def bag_dir
      Pathname.new(bag.bag_dir)
    end

    def data_dir
      Pathname.new(bag.data_dir)
    end

    # Get the absolute paths of all files
    def files
      Dir.glob(bag_dir/"**"/"*")
        .map {|f| Pathname.new(f) }
        .reject(&:directory?)
    end

    # Get the absolute paths of the files under the data directory
    def data_files
      bag.bag_files.map {|f| Pathname.new(f) }
    end

    def chipmunk_info_txt_file
      bag_dir/"chipmunk-info.txt"
    end

    attr_reader :bag
  end
end

