# frozen_string_literal: true

class BagRepository

  def initialize(klass)
    @klass = klass
  end

  def for(object)
    for_package(object)
  end

  private

  attr_reader :klass

  def for_package(package)
    raise "package must be stored" unless package.stored?

    klass.new(package.storage_location)
  end

end
