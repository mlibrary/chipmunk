# frozen_string_literal: true

require "chipmunk/status"

class PackageMove

  def initialize(id, source_volume, dest_volume)
    @id = id
    @source_volume = source_volume
    @dest_volume = dest_volume
  end

  attr_writer :repository

  def call
    package = repository.find(
      id: id,
      volume: source_volume
    )
    repository.save(
      package: package,
      volume: dest_volume
    )
    Chipmunk::Status.success
  end

  private

  attr_reader :id, :source_volume, :dest_volume

  def repository
    @repository ||= Services.packages
  end

end
