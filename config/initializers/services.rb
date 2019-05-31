# frozen_string_literal: true

require "chipmunk"

def assign_db(lhs, rhs)
  if rhs.is_a? String
    lhs.url = rhs
  elsif rhs.respond_to?(:has_key?)
    if rhs["url"]
      lhs.url = rhs["url"]
    else
      lhs.opts = rhs
    end
  end
end

assign_db(Checkpoint::DB.config, Chipmunk.config.checkpoint.database)
assign_db(Keycard::DB.config, Chipmunk.config.keycard.database)

if Chipmunk.config.keycard&.access
  Keycard.config.access = Chipmunk.config.keycard.access
end

Chipmunk.config.upload.tap do |upload|
  %w[upload_path storage_path].each do |option|
    path = upload[option].to_s.strip
    raise ArgumentError, "Configuration option upload.#{option} must not be empty" if path.empty?
    upload[option] = Rails.root.join(path).to_s unless path.start_with?("/")
  end
end

Services = Canister.new
# TODO: consult the environment-specific configuration for a set of volumes
Services.register(:incoming_storage) do
  Chipmunk::IncomingStorage.new(volume: Chipmunk::Volume.new(
    name: "incoming", package_type: Chipmunk::Bag, root_path: Chipmunk.config.upload.upload_path
  ))
end
Services.register(:storage) do
  Chipmunk::PackageStorage.new(volumes: [
      Chipmunk::Volume.new(name: "root", package_type: Chipmunk::Bag, root_path: "/"), # For migration purposes
      Chipmunk::Volume.new(name: "bags", package_type: Chipmunk::Bag, root_path: Chipmunk.config.upload.storage_path)
  ])
end
Services.register(:request_attributes) { Keycard::Request::AttributesFactory.new }
Services.register(:checkpoint) do
  Checkpoint::Authority.new(agent_resolver: KCV::AgentResolver.new,
                            credential_resolver: Chipmunk::RoleResolver.new,
                            resource_resolver: Chipmunk::ResourceResolver.new)
end
