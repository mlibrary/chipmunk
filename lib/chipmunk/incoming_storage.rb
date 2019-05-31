# frozen_string_literal: true

module Chipmunk
  # IncomingStorage is a factory for proxies to storage of incoming deposits.
  class IncomingStorage

    # Create an IncomingStorage instance.
    def initialize(volume:)
      @volume = volume
    end

    def for(package)
      raise Chipmunk::PackageAlreadyStoredError, package if package.stored?

      volume.get(upload_path(package))
    end

    def include?(package)
      volume.include?(upload_path(package))
    end

    private

    def upload_path(package)
      File.join("/", package.user.username, package.bag_id)
    end

    attr_reader :volume
  end
end
