module Chipmunk
  class Bag
    class Reader
      def at(path)
        Chipmunk::Bag.new(path)
      end

      def format
        "bag"
      end
    end
  end
end
