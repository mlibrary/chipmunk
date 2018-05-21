# frozen_string_literal: true

def collection_actions
  [:index?, :create?]
end

def resource_actions
  [:show?, :update?, :destroy?]
end

def allows_action?(action)
  if described_class <= CollectionPolicy
    described_class.new(user).public_send(action)
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

def it_resolves(subscope)
  describe "#resolve" do
    it "returns scope.#{subscope}" do
      resolved = double(subscope)
      scope = double(:scope, subscope => resolved)
      expect(described_class.new(user, scope).resolve).to be(resolved)
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
