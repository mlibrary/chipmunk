require "fileutils"
require "pathname"

module Chipmunk
  module Destination

    # A destination that is written to by renaming (moving) the root
    # path of the file tree to be written.
    class Rename
      def initialize(dest_root)
        @dest_root = Pathname.new(dest_root)
      end

      attr_reader :dest_root

      def write(root_path, _relative_files)
        FileUtils.mkdir_p dest_root
        File.rename root_path, dest_root
      end
    end

  end
end
