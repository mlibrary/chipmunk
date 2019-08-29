module Chipmunk
  class Bag
    class MoveWriter
      def write(bag, path)
        FileUtils.mkdir_p(path)
        File.rename(bag.path, path)
      end

      def storage_format
        Bag.storage_format
      end
    end
  end
end
