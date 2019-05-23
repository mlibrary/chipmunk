# frozen_string_literal: true

require "rspec/expectations"

class FakeUser < OpenStruct

  def initialize(hash = {})
    user_name = Faker::Internet.user_name
    super({ username:   user_name,
            identity:   {},
            admin?:     false,
            known?:     true,
            id:         rand(9999),
            agent_type: "user",
            agent_id:   user_name }.merge(hash))
  end

  def grant_role!(role, content_type)
    Services.checkpoint.grant!(self,
      Checkpoint::Credential::Role.new(role),
      Checkpoint::Resource::AllOfType.new(content_type))
  end

  def self.admin
    new.tap do |u|
      Services.checkpoint.grant!(u,
        Checkpoint::Credential::Role.new("admin"),
        Checkpoint::Resource::AllOfAnyType.new)
    end
  end

  def self.with_role(role, content_type)
    new.tap do |u|
      u.grant_role!(role, content_type)
    end
  end

  def self.with_external_identity(username = Faker::Internet.user_name)
    new(
      known?: false,
      user_name: nil,
      id: nil,
      agent_id: nil,
      identity: { username: username }
    )
  end
end

class FakeCollection < OpenStruct
  attr_reader :scopes

  def initialize(scopes = [], **kwargs)
    super(**kwargs)
    @scopes = scopes
  end

  def all
    chain :all
  end

  def none
    chain :none
  end

  def owned(user_id)
    chain [:owned, user_id]
  end

  def with_type(type)
    chain [:type, type]
  end

  def with_id(id)
    chain [:id, id]
  end

  def for_packages(package_relation)
    chain [:packages, package_relation]
  end

  def with_type_and_id(type, id)
    chain [:type_and_id, type, id]
  end

  def chain(scope)
    FakeCollection.new(scopes + [scope])
  end

  def or(other)
    FakeCollection.new(scopes + other.scopes)
  end
end

# Implicit subject is OK for these concise spec generator helpers
# rubocop:disable RSpec/ImplicitSubject

RSpec::Matchers.define :allow_action do |action|
  match do |policy|
    policy.public_send(action)
  end

  description do
    "allow action #{action}"
  end
end

def it_allows(*actions)
  actions.each do |action|
    it { is_expected.to allow_action(action) }
  end
end

def it_forbids(*actions)
  actions.each do |action|
    it { is_expected.not_to allow_action(action) }
  end
end

RSpec::Matchers.define :resolve do |*expected|
  match do |policy|
    actual = policy.resolve

    if actual.is_a? FakeCollection
      actual = actual.scopes
    end
    @scopes = actual

    actual.length == expected.length && expected.all? do |scope|
      actual.include?(scope) || actual.include?([:type, scope.to_s])
    end
  end
  description do
    "resolves to #{expected}"
  end
  failure_message do |policy|
    "expected that #{policy.class} would resolve to #{expected}, but it resolves to #{@scopes}"
  end
  failure_message_when_negated do |policy|
    "expected that #{policy.class} would not resolve to #{expected}, but it did"
  end
end

def it_resolves(*scope)
  it { is_expected.to resolve(*scope) }
end

RSpec::Matchers.define :have_base_scope do |resource_type, scope|
  match do |policy|
    actual = policy.base_scope
    actual == resource_type.public_send(scope)
  end

  description do
    "have a base scope of '#{resource_type}.#{scope}'"
  end
end

def it_has_base_scope(resource_type, scope)
  it { is_expected.to have_base_scope(resource_type, scope) }
end

# rubocop:enable RSpec/ImplicitSubject
