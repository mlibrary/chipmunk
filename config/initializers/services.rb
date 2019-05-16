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

SemanticLogger.default_level = (ENV["LOG_LEVEL"] || :info).to_sym
SemanticLogger.add_appender(file_name: 'log/chipmunk.log', formatter: :color)

Services = Canister.new.tap do |canister|
  canister.register(:request_attributes) { Keycard::Request::AttributesFactory.new }
  canister.register(:checkpoint) do
    Checkpoint::Authority.new(agent_resolver: KCV::AgentResolver.new)
  end
  canister.register(:packages) do
    Chipmunk::Package::Repository.new(adapters: {
      "none"  => Chipmunk::Package::NullStorage.new,
      "tmp"   => Chipmunk::Bag::DiskStorage.new(Chipmunk.config.upload.rsync_point),
      "bag:1" => Chipmunk::Bag::DiskStorage.new(Chipmunk.config.upload.storage_path),
    })
  end
end
