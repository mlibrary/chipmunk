# frozen_string_literal: true

def new_permit(agent, credential, resource, zone: Checkpoint::DB::Permit.default_zone)
  Checkpoint::DB::Permit.from(agent, credential, resource, zone: zone)
end

def agent(type: "user", id: "userid")
  actor = double("actor", agent_type: type, id: id)
  Checkpoint::Agent.new(actor)
end

def make_role(name)
  Checkpoint::Credential::Role.new(name)
end

def make_permission(name)
  Checkpoint::Credential::Permission.new(name)
end

def all_resources
  Checkpoint::Resource.all
end

def resource(type: "resource", id: 1)
  entity = double("entity", resource_type: type, id: id)
  Checkpoint::Resource.from(entity)
end
