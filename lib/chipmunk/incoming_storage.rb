# frozen_string_literal: true

require "pathname"

module Chipmunk
  # IncomingStorage is a factory for proxies to storage of incoming deposits.
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
    def initialize(volume:, paths:, links: )
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
