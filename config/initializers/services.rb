if Chipmunk.config.checkpoint&.database
    Checkpoint::DB.config.opts = Chipmunk.config.checkpoint.database
end
