# frozen_string_literal: true

module Chipmunk
  class Package
    # Extremely minimal null storage implementation; likely to give way to a
    # memory implementation, but useful for a default collaborator for now.
    class NullStorage
      def get(_id)
        nil
      end

      def exists?(_id)
        false
      end

      def save(_package)
        raise NotImplementedError
      end
    end
  end
end
