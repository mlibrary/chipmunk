# frozen_string_literal: true

require "chipmunk/volume"
require "chipmunk/errors"

module Chipmunk
  class Package
    # Primary interface for finding and storing packages.
    class Repository
      # Create a Package Repository.
      #
      # @param adapters: [Hash<Volume, Storage>] a map of volumes to storage
      #   adapters to register; equivalent to registering each individually
      def initialize(adapters: {})
        @adapters = {}
        adapters.each do |volume, adapter|
          register volume, adapter
        end
      end

      # Find a specific package in the repository.
      #
      # @param volume: [Volume|Symbol|String] the volume of package to find; coerced to Volume
      # @param id: [String] the id of the package to find
      # @raise [Chipmunk::UnsupportedVolumeError] if there is no storage adapter
      #   for the specified volume
      # @raise [Chipmunk::PackageNotFoundError] if there is no package of the
      #   given volume with the given id
      # @return [Chipmunk::Package] the package from the repository, bound to storage
      # TODO: Work through the descriptor notion here... Specific concerns:
      #       1. If IDs in the repository can be unique across volumes, id may suffice.
      #       2. The Package model currently holds absolute paths; some of that
      #          responsibility belongs here or at the storage level, regardless
      #          of whether it goes in a table in the same database.
      #       3. There are at least three kinds of identifiers in play already;
      #          what is the right one (or set) to be usable at the package
      #          repository and storage levels?
      #       4. The Storage interface now is using the term ID with the notion that
      #          the identifiers would be directly resolvable (by string manipulation
      #          only) to storage locations, but implementations may need to be wired
      #          up with a collaborator that can do a lookup, at least in transition.
      def find(volume:, id:)
        volume = Volume.new(volume)
        unsupported_volume!(volume) unless supports?(volume)

        adapters[volume].get(id).tap do |package|
          not_found!(volume, id) if package.nil?
        end
      end

      # Check if a specific package exists in the repository
      #
      # @param volume: [Volume|Symbol|String] the volume of package to find; coerced to Volume
      # @param id: [String] the id of the package to find
      # @return [Boolean]
      def exists?(volume:, id:)
        volume = Volume.new(volume)
        supports?(volume) && adapters[volume].exists?(id)
      end

      # Save the given package into the given volume. Any errors raises by the underlying
      # storage are not caught. Possible reasons an underlying storage adapter may raise
      # an error include insufficient disk space, an unrecognized package type, or trying
      # to save a duplicate package.
      #
      # @param volume: [Volume|Symbol|String] the volume of package; coerced to Volume
      # @param [Chipmunk::Package]
      # @raise [Chipmunk::UnsupportedVolumeError] if there is no storage adapter
      #   for the specified volume
      def save(volume:, package:)
        volume = Volume.new(volume)
        unsupported_volume!(volume) unless supports?(volume)

        adapters[volume].save(package)
      end

      # Register a storage adapter for a given package volume.
      #
      # @param volume [Volume|Symbol|String] the volume identifier for the adapter;
      #   coerced to Volume
      # @param adapter [Storage] the storage adapter that manages this volume
      def register(volume, adapter)
        adapters[Volume.new(volume)] = adapter
      end

      # Check whether a given volume is supported by this package repository.
      #
      # @param volume [Volume|Symbol|String] the volume to test; coerced to Volume
      # @return [Boolean] true when there is a registered adapter for the named
      #   volume; false otherwise
      def supports?(volume)
        adapters.has_key? Volume.new(volume)
      end

      private

      def not_found!(volume, id)
        raise Chipmunk::PackageNotFoundError, "Package of type '#{volume}' not found with id: #{id}"
      end

      def unsupported_volume!(volume)
        raise Chipmunk::UnsupportedVolumeError, "Package Repository does not support volume: #{volume}"
      end

      attr_reader :adapters
    end
  end
end
