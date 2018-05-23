# frozen_string_literal: true

require "spec_helper"
require_relative "policy_helpers"
require_relative "../support/checkpoint_helpers"
require "user_attributes"
require "ostruct"

RSpec.describe PackagePolicy do
  class FakeUser < OpenStruct
    def initialize(hash={})
      user_name = Faker::Internet.user_name
      super({username: user_name,
             identity: UserAttributes.new,
             admin?: false,
             agent_type: "user",
             agent_id: user_name}.merge(hash))
    end
  end

  let(:resource) do
    double(:resource, 
           user: double, 
           resource_type: Faker::Lorem.word,
           id: 1)
  end

  context "as an admin user" do
    let(:user) { FakeUser.new(admin?: true) }
    it_allows :show?
    it_disallows :update?, :destroy?
  end

  context "as a non-admin user with username" do
    let(:user) { FakeUser.new() }

    context "with an owned resource" do
      before(:each) { allow(resource).to receive(:user).and_return(user) }

      it_allows :show?
      it_disallows :update?, :destroy?
    end

    context "with an unowned resource" do
      it_disallows :show?, :update?, :destroy?
    end
  end

  context "as a user with identity but no username" do
    let(:username) { Faker::Internet.user_name }
    let(:user) do 
      FakeUser.new(admin?: false, 
                   user_name: nil, 
                   agent_id: nil,
                   identity: UserAttributes.new(username: username))
    end

    after(:each) do
      Checkpoint::DB.db[:permits].delete
    end

    context "with a grant for that user & resource" do
      before(:each) do 
        new_permit(agent(type: 'username', id: username),
                   make_permission(:show),
                   Checkpoint::Resource::AllOfType.new(resource.resource_type)).save
      end

      it_allows :show?
      it_disallows :update?, :destroy?
    end
    
    context "with a grant for a different user" do
      before(:each) do 
        new_permit(agent(type: 'username', id: Faker::Internet.user_name),
                   make_permission(:show),
                   Checkpoint::Resource::AllOfType.new(resource.resource_type)).save
      end

      it_disallows :show?, :update?, :destroy?
    end

    context "without a grant for that user & resource" do
      it_disallows :show?, :update?, :destroy?
    end
  end
end
