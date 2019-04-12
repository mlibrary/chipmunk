# frozen_string_literal: true

require "rails_helper"

RSpec.describe Package, type: :model do
  let(:upload_path) { Rails.application.config.upload["upload_path"] }
  let(:upload_link) { Rails.application.config.upload["rsync_point"] }
  let(:storage_path) { Rails.application.config.upload["storage_path"] }
  let(:uuid) { "6d11833a-d5fd-44f8-9205-277218578901" }

  [:bag_id, :user_id, :external_id, :storage_location, :content_type].each do |field|
    it "#{field} is required" do
      expect(Fabricate.build(:package, field => nil)).not_to be_valid
    end
  end

  it "can be valid" do
    expect(Fabricate(:package)).to be_valid
  end

  [:bag_id, :external_id].each do |field|
    it "#{field} must be unique" do
      expect do
        2.times { Fabricate(:package, field.to_sym => "something") }
      end.to raise_error ActiveRecord::RecordNotUnique
    end
  end

  it "is not valid with a bag id shorter than 6 characters" do
    package = Fabricate.build(:package, user: Fabricate(:user), bag_id: "short")
    expect(package).not_to be_valid
  end

  it "has an source path based on the user and the bag id" do
    user = Fabricate.build(:user, username: "someuser")
    request = Fabricate.build(:package, user: user, bag_id: uuid)
    expect(request.src_path).to eq(File.join(upload_path, "someuser", uuid))
  end

  describe "#dest_path" do
    it "is based on the storage path and bag id with three levels of hierarchy" do
      request = Fabricate.build(:package, bag_id: uuid)
      expect(request.dest_path).to eq(File.join(storage_path, "6d", "11", "83", uuid))
    end

    it "raises an exception if the bag id is shorter than 6 characters" do
      request = Fabricate.build(:package, bag_id: "short")
      expect { request.dest_path }.to raise_error RuntimeError
    end
  end

  it "has an upload link based on the rsync point and bag id" do
    request = Fabricate.build(:package, bag_id: uuid)
    expect(request.upload_link).to eq(File.join(upload_link, uuid))
  end

  describe "#external_validation_cmd" do
    let(:package) { Fabricate.build(:package) }

    context "when there is an external command configured" do
      around(:each) do |example|
        old_ext_validation = Rails.application.config.validation["external"]
        Rails.application.config.validation["external"] = { package.content_type => "/bin/true" }
        example.run
        Rails.application.config.validation["external"] = old_ext_validation
      end

      it "returns a command starting with the configured executable" do
        expect(package.external_validation_cmd).to match(/^\/bin\/true/)
      end
    end

    context "when there is no external command configured" do
      around(:each) do |example|
        old_ext_validation = Rails.application.config.validation["external"]
        Rails.application.config.validation["external"] = {}
        example.run
        Rails.application.config.validation["external"] = old_ext_validation
      end

      it "returns nil" do
        expect(package.external_validation_cmd).to be_nil
      end
    end
  end

  describe "#bagger_profile" do
    around(:each) do |example|
      old_profile = Rails.application.config.validation["bagger_profile"]["audio"]
      Rails.application.config.validation["bagger_profile"]["audio"] = "foo"
      example.run
      Rails.application.config.validation["bagger_profile"]["audio"] = old_profile
    end

    it "returns a bagger profile" do
      expect(Fabricate.build(:package).bagger_profile).not_to be_nil
    end
  end

  describe "#to_param" do
    it "uses the bag id" do
      bag_id = "made_up"
      expect(Fabricate.build(:package, bag_id: bag_id).to_param).to eq(bag_id)
    end
  end

  describe "#resource_type" do
    it "returns the content type" do
      package = Fabricate.build(:package, content_type: Faker::Lorem.word)
      expect(package.resource_type).to eq(package.content_type)
    end
  end
end
