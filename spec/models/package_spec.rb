# frozen_string_literal: true

require "rails_helper"

RSpec.describe Package, type: :model do
  let(:upload_path) { Rails.application.config.upload["upload_path"] }
  let(:upload_link) { Rails.application.config.upload["rsync_point"] }
  let(:storage_path) { Rails.application.config.upload["storage_path"] }
  let(:uuid) { "6d11833a-d5fd-44f8-9205-277218578901" }

  [:bag_id, :user_id, :external_id, :format, :content_type].each do |field|
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

  it "has an upload link based on the rsync point and bag id" do
    request = Fabricate.build(:package, bag_id: uuid)
    expect(request.upload_link).to eq(File.join(upload_link, uuid))
  end

  # TODO: This group's ugliness is because we have odd and temporary coupling between
  # Package and Bag::Validator. Once the ingest/storage phases are separated, this will
  # clean up considerably. See PFDR-184.
  describe "#valid_for_ingest?" do
    context "with an unstored bag" do
      let(:package)   { Fabricate.build(:unstored_package) }
      let(:validator) { double(:validator) }
      let(:disk_bag)  { double(:bag) }

      before(:each) do
        allow(Services.incoming_storage).to receive(:include?).with(package).and_return(true)
        allow(Services.incoming_storage).to receive(:for).with(package).and_return(disk_bag)
        allow(Chipmunk::Bag::Validator).to receive(:new).with(package, anything, disk_bag).and_return(validator)
      end

      it "validates the bag with its validator" do
        expect(validator).to receive(:valid?)
        package.valid_for_ingest?
      end
    end

    context "with a stored bag" do
      let(:package) { Fabricate.build(:stored_package) }
      let(:result)  { package.valid_for_ingest? }

      it "fails" do
        expect(result).to be false
      end

      it "does not create or use the bag validator" do
        expect(Chipmunk::Bag::Validator).not_to receive(:new)
        result
      end
    end

    context "with a bag with a bad path" do
      let(:package) { Fabricate.build(:stored_package) }
      let(:result)  { package.valid_for_ingest? }

      before(:each) do
        allow(Services.incoming_storage).to receive(:include?).and_return(false)
      end

      it "fails" do
        expect(result).to be false
      end

      it "does not create or use the bag validator" do
        expect(Chipmunk::Bag::Validator).not_to receive(:new)
        result
      end
    end

    context "with a plain zip" do
      let(:package) { Fabricate.build(:stored_package) }
      let(:result)  { package.valid_for_ingest? }

      it "fails" do
        expect(result).to be false
      end

      it "does not create or use the bag validator" do
        expect(Chipmunk::Bag::Validator).not_to receive(:new)
        result
      end
    end
  end

  describe "#external_validation_cmd" do
    let(:package) { Fabricate.build(:package) }
    let(:bag) { double(:bag, path: "/incoming/bag") }

    before(:each) do
      allow(Services.incoming_storage).to receive(:for).and_return(bag)
    end

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

      it "includes the path to the source archive" do
        expect(package.external_validation_cmd).to match("/incoming/bag")
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

  describe Package::AnyPackage do
    let(:resolver) { Chipmunk::ResourceResolver.new }
    let(:any_package) { Package::AnyPackage.new }

    it "expands to all configured package types" do
      expect(resolver.expand(any_package).map {|r| r.token.to_s }).to include(
        "digital:(all)",
        "audio:(all)",
        "video:(all)",
        "Package:(all)",
        "(all):(all)"
      )
    end

    it "converts to Package:(all)" do
      expect(resolver.convert(any_package).token.to_s).to eq("Package:(all)")
    end
  end
end
