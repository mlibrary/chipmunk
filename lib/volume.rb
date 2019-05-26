# frozen_string_literal: true

require "pathname"

# A named storage volume for a given format. This assumes for now that volumes
# are accessible via normal disk (File/IO) operations.
class Volume
  # @return [String] the name of the volume
  attr_reader :name

  # @return [Symbol] the format of the volume
  attr_reader :format

  # @return [Pathname] the absolute path to the storage root of the volume
  attr_reader :root_path

  # Create a new Volume.
  #
  # @param name [String] the name of the Volume; coerced to String
  # @param format [Symbol] the format of the Volume; coerced to Symbol
  # @param root_path [String|Pathname] the path to the storage root for this Volume;
  #   must be absolute; coerced to Pathname
  # @raise [ArgumentError] if the name is blank or root_path is relative
  def initialize(name:, format:, root_path:)
    @name = name.to_s
    @format = format.to_sym
    @root_path = Pathname(root_path)
    validate!
  end

  private

  def validate!
    raise ArgumentError, "Volume name must not be blank" if name.strip.empty?
    raise ArgumentError, "Volume format must not be blank" if format.to_s.strip.empty?
    raise ArgumentError, "Volume root_path must be absolute (#{root_path})" unless root_path.absolute?
  end
end
