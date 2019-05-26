# frozen_string_literal: true

module Chipmunk
  class FileNotFoundError < StandardError; end
  class PackageNotStoredError < StandardError; end
  class UnsupportedFormatError < StandardError; end
  class VolumeNotFoundError < StandardError; end
end
