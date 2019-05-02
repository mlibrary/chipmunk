# frozen_string_literal: true

module Chipmunk
  # A collection of files as stored in a repository.
  #
  # This is an abstract interface for packages that may conform to different
  # formats or specifications, such as BagIt or the Oxford Common Filesystem
  # Layout.
  class Package
    def chipmunk_info
      {}
    end
  end
end

require_relative "package/repository"
require_relative "package/null_storage"
