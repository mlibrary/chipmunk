# frozen_string_literal: true

require 'rspec/expectations'

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

  def grant_role!(role,content_type)
    Services.checkpoint.grant!(self,
                               Checkpoint::Credential::Role.new(role),
                               Checkpoint::Resource::AllOfType.new(content_type))
  end

  def self.admin
    self.new.tap do |u|
      Services.checkpoint.grant!(u,
                                 Checkpoint::Credential::Role.new('admin'),
                                 Checkpoint::Resource::AllOfAnyType.new)
    end
  end

  def self.with_role(role,content_type)
    self.new.tap do |u|
      u.grant_role!(role,content_type)
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
  def all
    :all
  end

  def none
    :none
  end

  def owned(user_id)
    [:owned, user_id]
  end

  def with_type(type)
    [:type, type]
  end

  def with_id(id)
    [:id, id]
  end

  def for_packages(package_relation)
    [:packages, package_relation]
  end

  def with_type_and_id_(type, id)
    [:type_and_id, type, id]
  end

  def any_of(scopes)
    scopes
  end
end

RSpec::Matchers.define :allow_action do |action|
  match do |policy|
    policy.public_send(action)
  end
end

RSpec::Matchers.define :forbid_action do |action|
  match do |policy|
    !policy.public_send(action)
  end
end

def allows_action?(action)
  if described_class <= CollectionPolicy
    described_class.new(user, FakeCollection.new).public_send(action)
  elsif described_class <= ResourcePolicy
    described_class.new(user, resource).public_send(action)
  else
    raise "#{described_class} is not a subclass of CollectionPolicy or ResourcePolicy"
  end
end

def it_allows(*actions)
  actions.each do |action|
    it "allows #{action}" do
      expect(subject).to allow_action(action)
    end
  end
end

def it_disallows(*actions)
  actions.each do |action|
    it "forbids #{action}" do
      expect(subject).not_to allow_action(action)
    end
  end
end

def it_forbids(*actions)
  actions.each do |action|
    it "forbids #{action}" do
      expect(subject).not_to allow_action(action)
    end
  end
end

RSpec::Matchers.define :resolve do |*expected|
  match do |policy|
    actual = policy.resolve
    if expected.length > 1
      actual.length == expected.length && expected.map do |scope|
        actual.include?(scope) || actual.include?([:type,scope.to_s])
      end.all?
    else
      case expected[0]
      when :all
        actual == :all || actual == [:all]
      when :none
        actual == :none || actual == []
      else
        actual == expected[0] || actual == [[:type,expected[0].to_s]]
      end
    end
  end
  failure_message do |policy|
    "expected that #{policy.class} would resolve to #{expected}, but it resolves to #{actual}"
  end
  failure_message_when_negated do |policy|
    "expected that #{policy.class} would not resolve to #{expected}, but it did"
  end
end

def it_resolves(scope)
  describe "#resolve" do
    it "resolves to #{scope}" do
      expect(subject).to resolve(scope)
    end
  end
end

def it_resolves_owned
  describe "#resolve" do
    it "resolves using the owned scope with the current user" do
      expect(described_class).to resolve([:owned, user.id])
    end
  end
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
