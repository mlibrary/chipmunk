# frozen_string_literal: true

require "checkpoint"

module Chipmunk
  class RoleResolver < Checkpoint::Credential::RoleMapResolver

    def initialize
      super(
        admin: [:show, :create, :edit],
        content_manager: [:show, :create, :edit],
        viewer: [:show],
      )
    end
  end

  class ResourceResolver < Checkpoint::Resource::Resolver
    def expand(entity)
      if entity.respond_to?(:to_resources)
        entity.to_resources + super(entity)
      else
        super(entity)
      end
    end
  end
end
