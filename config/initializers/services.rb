# frozen_string_literal: true

def assign_db(lhs, rhs)
  case rhs
  when String
    lhs.url = rhs
  when Hash
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

Services = Canister.new

Services.register(:checkpoint) { Checkpoint::Authority.new(agent_resolver: AgentResolver.new) }
require "chipmunk_bag"
Services.register(:storage) { ChipmunkBag }
