# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  def minimal_user
    User.new(email: Faker::Internet.email,
             username: Faker::Internet.user_name)
  end

  [:email, :admin, :api_key_digest, :username].each do |field|
    it "#{field} is required" do
      expect(Fabricate.build(:user, field => nil)).to_not be_valid
    end
  end

  describe "#email" do
    it "must be unique" do
      expect do
        Fabricate(:user, email: "test@example.com")
        Fabricate(:user, email: "test@example.com")
      end.to raise_error ActiveRecord::RecordNotUnique
    end
  end

  describe "#username" do
    it "must be unique" do
      expect do
        Fabricate(:user, username: "test")
        Fabricate(:user, username: "test")
      end.to raise_error ActiveRecord::RecordNotUnique
    end
  end

  describe "#admin" do
    it "defaults to false" do
      expect(minimal_user.admin).to be false
    end
  end

  describe "#api_key" do
    it "generates an api_key by default" do
      expect(minimal_user.api_key_digest).to_not be_nil
    end
    it "a user can be found by api_key" do
      user = User.create(email: Faker::Internet.email,
                         username: Faker::Internet.user_name)
      digest = user.api_key.digest
      expect(User.find_by_api_key_digest(digest)).to eql(user)
    end
    it "raises if we try to access a persisted user's key" do
      user = Fabricate(:user)
      expect { User.find(user.id).api_key.to_s }
        .to raise_error(Keycard::ApiKey::HiddenKeyError)
    end
  end
end
