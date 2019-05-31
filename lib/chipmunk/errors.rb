# frozen_string_literal: true

module Chipmunk
  class FileNotFoundError < StandardError; end
  class PackageNotFoundError < StandardError; end
  class PackageNotStoredError < StandardError; end
  class PackageAlreadyStoredError < StandardError; end
  class UnsupportedFormatError < StandardError; end
  class VolumeNotFoundError < StandardError; end
end
