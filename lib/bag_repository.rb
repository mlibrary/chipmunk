module Chipmunk
  class BagRepository

    def initialize(klass)
      @klass = klass
    end

    def create(path)
      klass.new(path)
    end

    private

    attr_reader :klass
  end
end
