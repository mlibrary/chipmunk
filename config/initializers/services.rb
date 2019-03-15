# frozen_string_literal: true

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

Services.register(:checkpoint) { Checkpoint::Authority.new(agent_resolver: AgentResolver.new) }
require "chipmunk_bag"
Services.register(:storage) { ChipmunkBag }
