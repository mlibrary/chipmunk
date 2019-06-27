# frozen_string_literal: true

require "checkpoint"

class RoleGranter
  attr_reader :user, :role

  def initialize(user, role, authority: Services.checkpoint)
    @user = user
    @role = Checkpoint::Credential::Role.new(role)
    @authority = authority
  end

  def on_everything
    grant! Checkpoint::Resource.all
  end

  def on_all(type)
    grant! Checkpoint::Resource::AllOfType.new(type)
  end

  def on(type, id)
    grant! Checkpoint::Resource::Token.new(type, id)
  end

  private

  def grant!(resource)
    authority.grant!(user, role, resource)
  end

  attr_reader :authority
end

module CanManageAccounts
  def me
    @me ||= Fabricate(:user, api_key_digest: my_api_key.digest)
  end

  def make_me_a(role)
    RoleGranter.new(me, role)
  end

  def my_api_key
    @my_api_key ||= Keycard::DigestKey.new
  end

  alias_method :make_me_an, :make_me_a
end

module MakesApiRequests
  def api_get(*args)
    set_auth_token
    get(*args)
  end

  def api_post(*args)
    set_auth_token
    post(*args)
  end

  def json_get(*args, default_on_failure: :no_default)
    JSON.parse(api_get(*args).body)
  rescue JSON::ParserError
    raise if default_on_failure == :no_default

    default_on_failure
  end

  def set_auth_token
    header("Authorization", "Token token=#{my_api_key}")
  end
end

World(CanManageAccounts)
World(MakesApiRequests)
