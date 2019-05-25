# frozen_string_literal: true

# PackageStorage is a factory for proxies to a Package's underlying storage.
# An instance supports a named set of format types, mapping each to a storage
# proxy class and creating an appropriate proxy instance for a package.
class PackageStorage

  # Create a PackageStorage instance.
  #
  # @param formats: [Hash<Symbol, Class>] a mapping of the format name to proxy class
  # @example
  #   PackageStorage.new(formats: { bag: Chipmunk::Bag })
  def initialize(formats:)
    @formats = formats
  end

  # Retrieve the storage proxy for a given package. The package must be stored and of a registered format.
  # @param package [Package] the package for which to retrieve a storage proxy
  # @raise [Chipmunk::PackageNotStoredError] if the package is not stored
  # @raise [Chipmunk::UnsupportedFormatError] if the package format is not registered
  def for(package)
    raise Chipmunk::PackageNotStoredError, package unless package.stored?

    factory(package.format).new(package.storage_location)
  end

  private

  def factory(format)
    formats[format.to_sym].tap do |type|
      raise Chipmunk::UnsupportedFormatError, format if type.nil?
    end
  end

  attr_reader :formats
end
