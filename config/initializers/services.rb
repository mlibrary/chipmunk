# frozen_string_literal: true

require "chipmunk_bag"

if Chipmunk.config.checkpoint&.database&.url
  Checkpoint::DB.config.url = Chipmunk.config.checkpoint.database.url
end

if Chipmunk.config.keycard&.database&.url
  Keycard::DB.config.url = Chipmunk.config.keycard.database.url
end

if Chipmunk.config.keycard&.access
  Keycard.config.access = Chipmunk.config.keycard.access
end

Services = Canister.new
Services.register(:storage) { ChipmunkBag }
Services.register(:request_attributes) { Keycard::Request::AttributesFactory.new }
Services.register(:checkpoint) do
  Checkpoint::Authority.new(agent_resolver: KCV::AgentResolver.new)
end

