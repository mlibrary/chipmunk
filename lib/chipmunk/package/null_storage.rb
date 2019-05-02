# frozen_string_literal: true

class Chipmunk::Package
  # Extremely minimal null storage implementation; likely to give way to a
  # memory implementation, but useful for a default collaborator for now.
  class NullStorage
    def get(id)
      nil
    end
  end
end
