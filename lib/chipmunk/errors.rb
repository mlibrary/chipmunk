# frozen_string_literal: true

module Chipmunk
  class FileNotFoundError < StandardError; end
  class PackageNotFoundError < StandardError; end
  class BagNotFoundError < PackageNotFoundError; end
  class UnsupportedVolumeError < StandardError; end
end
