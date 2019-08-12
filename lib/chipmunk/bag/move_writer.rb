module Chipmunk
  class Bag
    class MoveWriter
      def write(bag, path)
        FileUtils.mkdir_p(path)
        File.rename(bag.path, path)
      end

      def format
        Bag.format
      end
    end
  end
end
