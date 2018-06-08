# frozen_string_literal: true

class FakeUser < OpenStruct
  def initialize(hash={})
    user_name = Faker::Internet.user_name
    super({username: user_name,
           identity: UserAttributes.new,
           admin?: false,
           known?: true,
           id: rand(9999),
           agent_type: "user",
           agent_id: user_name}.merge(hash))
  end

  def self.with_external_identity(username=Faker::Internet.user_name)
    self.new(known?: false,
             user_name: nil,
             id: nil,
             agent_id: nil,
             identity: UserAttributes.new(username: username))
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
    [:owned,user_id]
  end

end

def allows_action?(action)
  if described_class <= CollectionPolicy
    described_class.new(user, FakeCollection.new()).public_send(action)
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
    end
  end
end

def it_disallows(*actions)
  actions.each do |action|
    it "is not allowed to #{action}" do
      expect(allows_action?(action)).to be(false)
    end
  end
end

def it_resolves(scope)
  describe "#resolve" do
    it "resolves to #{scope}" do
      expect(described_class.new(user, FakeCollection.new()).resolve).to eq(scope)
    end
  end
end

def it_resolves_owned
  describe "#resolve" do
    it "resolves using the owned scope with the current user" do
      expect(described_class.new(user, FakeCollection.new()).resolve).to eq([:owned, user.id])
    end
  end
end

def it_has_base_scope(scope)
  describe "#base_scope" do
    it "returns all events" do
      expect(described_class.new(double).base_scope).to eq(scope)
    end
  end
end
