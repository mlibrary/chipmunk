# frozen_string_literal: true

# A storage manager to keep track of named Volumes.
class VolumeManager
  attr_reader :volumes

  # Create a storage volume manager, registering each of the volumes
  # supplied. If any volumes have the same name, the last one in the array
  # with that name will be registered and the others discarded.
  #
  # @param volumes [Array<Volume>] the Volumes to register
  def initialize(volumes:)
    @volumes = Hash[volumes.map {|volume| [volume.name, volume] }].freeze
  end

  # Retrieve a volume of a given name.
  #
  # @param name [String] the name of the volume to find
  # @raise [Chipmunk::VolumeNotFoundError] if a volume with the given name is not registered
  def find(name)
    volumes[name.to_s].tap do |volume|
      raise Chipmunk::VolumeNotFoundError, name.to_s if volume.nil?
    end
  end
end
