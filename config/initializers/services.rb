if Chipmunk.config.checkpoint&.database
    Checkpoint::DB.config.opts = Chipmunk.config.checkpoint.database
end

Services = Canister.new

Services.register(:checkpoint) { Checkpoint::Authority.new(agent_resolver: AgentResolver.new) }

