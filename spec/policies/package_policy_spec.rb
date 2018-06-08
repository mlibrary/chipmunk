# frozen_string_literal: true

require "spec_helper"
require_relative "policy_helpers"
require_relative "../support/checkpoint_helpers"
require "user_attributes"
require "ostruct"

RSpec.describe PackagePolicy do
  let(:resource) do
    double(:resource, 
           user: double, 
           resource_type: Faker::Lorem.word,
           id: 1)
  end

  context "as an admin" do
    let(:user) { FakeUser.new(admin?: true) }
    it_allows :show?
    it_disallows :update?, :destroy?
  end

  context "as a persisted non-admin user" do
    let(:user) { FakeUser.new(admin?: false) }

    context "with an owned resource" do
      before(:each) { allow(resource).to receive(:user).and_return(user) }

      it_allows :show?
      it_disallows :update?, :destroy?
    end

    context "with an unowned resource" do
      it_disallows :show?, :update?, :destroy?
    end
  end

  context "as an externally-identified user" do
    let(:username) { Faker::Internet.user_name }
    let(:user) { FakeUser.with_external_identity(username) }

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
