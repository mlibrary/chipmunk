# frozen_string_literal: true

require "pathname"

module Chipmunk
  # IncomingStorage is responsible for the business rules of writing to and reading from
  # Volumes earmarked for its use. It is specifically concerned with initial upload of bags,
  # and makes them available to other parts of the system via its methods.
  class IncomingStorage

    class UserPathBuilder
      def initialize(root_path)
        @root_path = Pathname.new(root_path)
        raise ArgumentError, "root_path must not be nil" unless @root_path
      end

      def for(package)
        File.join(root_path, package.user.username, package.bag_id)
      end

      private

      attr_reader :root_path
    end

    class IdPathBuilder
      def initialize(root_path)
        @root_path = Pathname.new(root_path)
        raise ArgumentError, "root_path must not be nil" unless @root_path
      end

      def for(package)
        File.join(root_path, package.bag_id)
      end

      private

      attr_reader :root_path
    end

    # Create an IncomingStorage instance.
    # @param volume [Volume] The Volume from which the deposited packages should be ingested
    # @param paths [PathBuilder] A PathBuilder that returns a path on disk to the user upload
    #   location for a deposit, for a given package.
    # @param links [PathBuilder] A PathBuilder that returns an rsync destination to which the
    #   user should upload, for a given package.
    def initialize(volume:, paths:, links:)
      @volume = volume
      @paths = paths
      @links = links
    end

    def for(package)
      raise Chipmunk::PackageAlreadyStoredError, package if package.stored?

      volume.get(upload_path(package))
    end

    def include?(package)
      volume.include?(upload_path(package))
    end

    def upload_link(package)
      links.for(package)
    end

    private

    def upload_path(package)
      paths.for(package)
    end

    attr_reader :volume, :paths, :links
  end
end
