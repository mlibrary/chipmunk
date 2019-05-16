require "fileutils"
require "pathname"

module Chipmunk
  module Destination

    # A destination that is written to by copying each file from the
    # file tree to be written.
    class Copy
      def initialize(dest_root)
        @dest_root = Pathname.new(dest_root)
      end

      attr_reader :dest_root

      def write(root_path, relative_files)
        relative_files.each do |relative_path|
          FileUtils.mkdir_p dest_root/relative_path.parent
          IO.copy_stream(root_path/relative_path, dest_root/relative_path)
        end
      end
    end

  end
end
