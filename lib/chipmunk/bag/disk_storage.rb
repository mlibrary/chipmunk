# frozen_string_literal: true

module Chipmunk
  class Bag::DiskStorage
    attr_reader :root_path

    def initialize(root_path)
      @root_path = Pathname.new(root_path)
    end

    # Retrieve a stored Bag from disk.
    #
    # @param id [String] the identifier of the Bag to retrieve
    # @raise [Chipmunk::PackageNotFoundError] if the Bag is not found
    # @return [Chipmunk::Bag] the Bag, bound to this Storage instance
    def get(id)
      not_found!(id) unless bag_exists?(id)

      Bag.new(id: id, storage: self)
    end

    private

    def bag_exists?(id)
      File.exists? bag_path(id)
    end

    def bag_path(id)
      root_path/id
    end

    def not_found!(id)
      raise BagNotFoundError, "Bag not found with ID: #{id}"
    end
  end
end
