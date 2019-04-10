module Chipmunk
  class BagRepository

    def initialize(klass)
      @klass = klass
    end

    def create(path)
      klass.new(path)
    end

    def for_package(package)
      klass.new(package.storage_location)
    end

    private

    attr_reader :klass
  end
end
