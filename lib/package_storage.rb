# frozen_string_literal: true

# PackageStorage is a factory for proxies to a Package's underlying storage.
# An instance supports a named set of format types, mapping each to a storage
# proxy class and creating an appropriate proxy instance for a package.
class PackageStorage

  # Create a PackageStorage instance.
  #
  # TODO: unify VolumeManager and PackageStorage -- Volume should bind not only
  # its format name, but the storage proxy class; then this should take the volumes
  # and the volume manager is no longer needed. We only use volumes to encapsulate
  # the actual storage and storage proxy classes, so they should not leak from here.
  #
  # @param formats [Hash<Symbol, Class>] a mapping of the format name to proxy class
  # @param volume_manager [VolumeManager] the VolumeManager for the Volumes where
  #   packages are stored
  # @example
  #   PackageStorage.new(formats: { bag: Chipmunk::Bag }, volume_manager: a_volume_manager)
  def initialize(formats:, volume_manager:)
    @formats = formats
    @volume_manager = volume_manager
  end

  # Retrieve the storage proxy for a given package. The package must be stored and of a registered format.
  # @param package [Package] the package for which to retrieve a storage proxy
  # @raise [Chipmunk::PackageNotStoredError] if the package is not stored
  # @raise [Chipmunk::UnsupportedFormatError] if the package format is not registered
  def for(package)
    raise Chipmunk::PackageNotStoredError, package unless package.stored?

    storage_for(package.format).new(path_to(package))
  end

  private

  def storage_for(format)
    formats[format.to_sym].tap do |type|
      raise Chipmunk::UnsupportedFormatError, format if type.nil?
    end
  end

  def path_to(package)
    volume_for(package).expand(package.storage_path).to_s
  end

  def volume_for(package)
    volume_manager.find(package.storage_volume)
  end

  attr_reader :formats, :volume_manager
end
