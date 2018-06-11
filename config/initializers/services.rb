# frozen_string_literal: true

if Chipmunk.config.checkpoint&.database
  Checkpoint::DB.config.opts = Chipmunk.config.checkpoint.database
end

if Chipmunk.config.keycard&.database
  Keycard::DB.config.opts = Chipmunk.config.keycard.database
end

if Chipmunk.config.keycard&.access
  Keycard.config.access = Chipmunk.config.keycard.access
end

Services = Canister.new

Services.register(:checkpoint) { Checkpoint::Authority.new(agent_resolver: AgentResolver.new) }
Services.register(:storage) { ChipmunkBag }
