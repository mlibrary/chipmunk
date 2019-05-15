# frozen_string_literal: true

require "chipmunk/bag"
require "chipmunk/destination/rename"
require "chipmunk/errors"
require "bagit"
require "pathname"

module Chipmunk
  class Bag
    class DiskStorage
      attr_reader :root_path

      def initialize(root_path, dest_factory: Destination::Rename)
        @root_path = Pathname.new(root_path)
        @dest_factory = dest_factory
      end

      # Retrieve a stored Bag from disk.
      #
      # @param id [String] the identifier of the Bag to retrieve
      # @raise [Chipmunk::PackageNotFoundError] if the Bag is not found
      # @return [Chipmunk::Bag] the Bag, bound to this Storage instance
      def get(id)
        not_found!(id) unless bag_exists?(id)

        Bag.new(id: id, bag: BagIt::Bag.new(bag_path(id)))
      end

      def exists?(id)
        bag_exists?(id)
      end

      def save(package)
        package.copy(dest_factory.new(bag_path(package.id)))
      end

      private

      attr_reader :dest_factory

      def bag_exists?(id)
        valid_id?(id) && bag_path(id).exist?
      end

      def bag_path(id)
        root_path/File.join(*prefixes(id)[1..3], id)
      end

      def valid_id?(id)
        prefixes(id) != nil
      end

      def prefixes(id)
        id.match(/^(..)(..)(..).*/)
      end

      def not_found!(id)
        raise BagNotFoundError, "Bag not found with ID: #{id}"
      end
    end

    class FlatStorage < DiskStorage
      def bag_path(id)
        root_path/id
      end

      def valid_id?(id)
        !id.empty?
      end
    end
  end
end
