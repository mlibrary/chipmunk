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

  def with_type_and_id_(type, id)
    [:type_and_id, type, id]
  end

  def any_of(scopes)
    scopes
  end
end

RSpec::Matchers.define :allow_action do |action|
  match do |policy|
    if policy <= CollectionPolicy
      policy.new(user, FakeCollection.new).public_send(action)
    elsif policy <= ResourcePolicy
      policy.new(user, resource).public_send(action)
    else
      raise "#{described_class} is not a subclass of CollectionPolicy or ResourcePolicy"
    end
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
    it "is allowed to #{action}" do
      expect(allows_action?(action)).to be(true)
#      expect(described_class).to allow_action(action)
    end
  end
end

def it_disallows(*actions)
  actions.each do |action|
    it "is not allowed to #{action}" do
      expect(allows_action?(action)).to be(false)
#      expect(described_class).not_to allow_action(action)
    end
  end
end

RSpec::Matchers.define :resolve do |expected|
  match do |policy|
    actual = policy.new(user, FakeCollection.new).resolve

    case expected
    when :all
      actual == :all || actual == [:all]
    when :none
      actual == :none || actual == []
    else
      actual == expected
    end
  end
end

def it_resolves(scope)
  describe "#resolve" do
    it "resolves to #{scope}" do
      expect(described_class).to resolve(scope)
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

RSpec::Matchers.define :have_base_scope do |scope|
  match do |policy|
    policy.new(double).base_scope == scope
  end
end

def it_has_base_scope(scope)
  describe "#base_scope" do
    it "returns all events" do
      expect(described_class).to have_base_scope(scope)
    end
  end
end


