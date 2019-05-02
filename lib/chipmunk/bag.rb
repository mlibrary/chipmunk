# frozen_string_literal: true

require "bagit"

module Chipmunk
  class Bag
    include SemanticLogger::Loggable

    # The package ID
    attr_reader :id

    # @param storage: [Storage] a storage adapter for IO operations on the Bag
    # TODO: Decide how much a Chipmunk::Bag needs to access the storage/disk itself or
    #       if the BagIt::Bag bound to somewhere under the storage root is enough.
    # TODO: Reconcile the notions of Bags _inside_ the repository and _outside_ of it.
    #       Notably, the storage and repository are separate. We could potentially
    #       use read-only storage for items located by the repository and expose
    #       explicit or transactional operations for updates. We could also use
    #       less strict storage for in-flight packages. These are all draft thoughts
    #       seeking to clarify the role of Chipmunk::Bag -- does it have unmetered
    #       access to disk? There are parallel questions on the Package model.
    # TODO: Decide what the actual parameters should be here; who makes the
    #       BagIt::Bag? Does this inherit from Package or just implement all of
    #       that interface as it emerges?
    def initialize(path = :REMOVE, id: :REMOVE, storage: Package::NullStorage.new)
      if id == :REMOVE
        @id = path
        @bag = BagIt::Bag.new(path)
      else
        @id = id
        @bag = BagIt::Bag.new(storage.root_path/id)
      end
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
      new(package.storage_location)
    end

    def bag_dir
      Pathname.new(super)
    end

    def data_dir
      Pathname.new(super)
    end

    def chipmunk_info_txt_file
      bag_dir/"chipmunk-info.txt"
    end

    def chipmunk_info
      return {} unless File.exist?(chipmunk_info_txt_file)

      logger.debug "Delegating method 'read_info_file' to bag, caller: #{caller(1..1).first}"
      bag.send(:read_info_file, chipmunk_info_txt_file)
    end

    # Get the absolute paths of all files
    def files
      Dir.glob(bag_dir/"**"/"*")
        .map {|f| Pathname.new(f) }
        .reject(&:directory?)
    end

    # Get the paths of all files relative to the root of the bag
    # @see {#bag_dir}
    def relative_files
      files.map {|f| f.relative_path_from(bag_dir) }
    end

    # Get the absolute paths of the files under the data directory
    def data_files
      bag.bag_files.map {|f| Pathname.new(f) }
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

    def method_missing(name, *args, &block)
      if @bag.respond_to?(name)
        logger.debug "Delegating method '#{name}' to bag, caller: #{caller(1..1).first}"
        @bag.send(name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      bag.respond_to?(name) || super
    end

    private

    attr_reader :bag
  end
end

require_relative "bag/profile"
require_relative "bag/tag"
require_relative "bag/disk_storage"
require_relative "bag/validator"
