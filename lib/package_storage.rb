# frozen_string_literal: true

# PackageStorage is a factory for proxies to a Package's underlying storage.
# An instance supports a named set of format types, mapping each to a storage
# proxy class and creating an appropriate proxy instance for a package.
class PackageStorage

  # Create a PackageStorage instance.
  #
  # @param volumes [Array<Volume>] the storage volumes where packages are stored
  def initialize(volumes:)
    @volumes = Hash[volumes.map {|volume| [volume.name, volume] }]
  end

  # Retrieve the storage proxy for a given package. The package must be stored and of a registered format.
  # @param package [Package] the package for which to retrieve a storage proxy
  # @raise [Chipmunk::PackageNotStoredError] if the package is not stored
  # @raise [Chipmunk::UnsupportedFormatError] if the package format is not registered
  def for(package)
    raise Chipmunk::PackageNotStoredError, package unless package.stored?

    volume_for(package).get(package.storage_path)
  end

  def write(package, source)
    if package.format == Package::Format.bag
      move_bag(package, source)
    else
      raise Chipmunk::UnsupportedFormatError, "Package #{package.bag_id} has invalid format: #{package.format}"
    end
  end

  private

  def move_bag(package, source)
    bag_id = package.bag_id
    prefixes = bag_id.match(/^(..)(..)(..).*/)
    raise "bag_id too short: #{bag_id}" unless prefixes

    storage_path = File.join("/", prefixes[1..3], bag_id)
    volume = destination_volume(package)
    dest_path = volume.expand(storage_path)

    FileUtils.mkdir_p(dest_path)
    File.rename(source.path, dest_path)

    package.storage_volume = volume.name
    package.storage_path = storage_path
    true
  end

  def destination_volume(package)
    volumes["bags"].tap do |volume|
      raise Chipmunk::VolumeNotFoundError, "Cannot find destination volume: bags" if volume.nil?
    end
  end

  def volume_for(package)
    volumes[package.storage_volume].tap do |volume|
      raise Chipmunk::VolumeNotFoundError, package.storage_volume if volume.nil?
      unsupported_format!(volume, package) if volume.format != package.format
    end
  end

  def unsupported_format!(volume, package)
    raise Chipmunk::UnsupportedFormatError, "Volume #{volume.name} does not support #{package.format}"
  end

  attr_reader :volumes
end
