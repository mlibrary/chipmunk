module Chipmunk
  class Volume < String
    def initialize(obj)
      super(obj.to_s)
    end
  end
end
