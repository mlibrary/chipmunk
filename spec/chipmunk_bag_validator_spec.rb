# frozen_string_literal: true

require "rails_helper"
require "open3"

RSpec.describe ChipmunkBagValidator do
  def exitstatus(status)
    double(:exitstatus, exitstatus: status)
  end

  let(:queue_item) { Fabricate(:queue_item) }
  let(:package) { queue_item.package }
  let(:src_path) { queue_item.package.src_path }
  let(:dest_path) { queue_item.package.dest_path }
  let(:good_tag_files) { [File.join(src_path, "marc.xml")] }

  let(:chipmunk_info_db) do
    {
      "External-Identifier"   => package.external_id,
      "Chipmunk-Content-Type" => package.content_type,
      "Bag-ID"                => package.bag_id
    }
  end

  let(:chipmunk_info_with_metadata) do
    chipmunk_info_db.merge(
      "Metadata-Type"         => "MARC",
      "Metadata-URL"          => "http://what.ever",
      "Metadata-Tagfile"      => "marc.xml"
    )
  end

  # default (good case)
  let(:fakebag) { double("fake bag", valid?: true) }
  let(:ext_validation_result) { ["", "", exitstatus(0)] }
  let(:bag_info) { { "Foo" => "bar", "Baz" => "quux" } }
  let(:tag_files) { good_tag_files }
  let(:chipmunk_info) { chipmunk_info_with_metadata }

  let(:errors) { [] }

  around(:each) do |example|
    old_profile = Rails.application.config.validation["bagger_profile"]
    profile_uri = "file://" + Rails.root.join("spec", "support", "fixtures", "test-profile.json").to_s
    Rails.application.config.validation["bagger_profile"] = { "digital" => profile_uri, "audio" => profile_uri }
    example.run
    Rails.application.config.validation["bagger_profile"] = old_profile
  end

  describe "#valid?" do
    let(:validator) { described_class.new(package, errors, fakebag) }

    before(:each) do
      allow(File).to receive(:'exist?').with(src_path).and_return true
      allow(fakebag).to receive(:chipmunk_info).and_return(chipmunk_info)
      allow(fakebag).to receive(:tag_files).and_return(tag_files)
      allow(fakebag).to receive(:bag_info).and_return(bag_info)
      allow(Open3).to receive(:capture3).and_return(ext_validation_result)
    end

    shared_examples_for "an invalid item" do |error_pattern|
      it "records the validation error" do
        validator.valid?
        expect(errors).to include a_string_matching error_pattern
      end

      it "returns false" do
        expect(validator.valid?).to be false
      end
    end

    context "when the bag is valid" do
      context "and its metadata matches the queue item" do
        it "returns true" do
          expect(validator.valid?).to be true
        end
      end

      context "but its external ID does not match the queue item" do
        let(:chipmunk_info) { chipmunk_info_with_metadata.merge("External-Identifier" => "something-different") }

        it_behaves_like "an invalid item", /External-Identifier/
      end

      context "but its bag ID does not match the queue item" do
        let(:chipmunk_info) { chipmunk_info_with_metadata.merge("Bag-ID" => "something-different") }

        it_behaves_like "an invalid item", /Bag-ID/
      end

      context "but its package type does not match the queue item" do
        let(:chipmunk_info) { chipmunk_info_with_metadata.merge("Chipmunk-Content-Type" => "something-different") }

        it_behaves_like "an invalid item", /Chipmunk-Content-Type/
      end

      context "but does not include the referenced metadata file" do
        let(:tag_files) { [] }

        it_behaves_like "an invalid item", /Missing.*marc.xml/
      end

      context "but does not any include descriptive metadata tags" do
        let(:chipmunk_info) { chipmunk_info_db }
        let(:tag_files) { [] }

        it "returns true" do
          expect(validator.valid?).to be true
        end
      end

      context "but has only some descriptive metadata tags" do
        let(:chipmunk_info) do
          chipmunk_info_db.merge(
            "Metadata-URL"          => "http://what.ever",
            "Metadata-Tagfile"      => "marc.xml"
          )
        end

        it_behaves_like "an invalid item", /Metadata-Type/
      end

      context "but external validation fails" do
        around(:each) do |example|
          old_ext_validation = Rails.application.config.validation["external"]
          Rails.application.config.validation["external"] = { package.content_type => "something" }
          example.run
          Rails.application.config.validation["external"] = old_ext_validation
        end

        let(:chipmunk_info) { chipmunk_info_with_metadata }
        let(:ext_validation_result) { ["external output", "external error", exitstatus(1)] }

        it_behaves_like "an invalid item", /external error/
      end

      context "but the package type has no external validation command" do
        around(:each) do |example|
          old_ext_validation = Rails.application.config.validation["external"]
          Rails.application.config.validation["external"] = {}
          example.run
          Rails.application.config.validation["external"] = old_ext_validation
        end

        it "does not try to run external validation" do
          expect(Open3).not_to receive(:capture3)
          validator.valid?
        end
      end
    end

    context "when the bag is invalid" do
      let(:bag_errors) { double("bag_errors", full_messages: ["injected error"]) }
      let(:fakebag) { double("fake bag", valid?: false, errors: bag_errors) }

      it_behaves_like "an invalid item", /Error validating.*\n  injected error$/

      it "does not try to run external validation" do
        expect(Open3).not_to receive(:capture3)
        validator.valid?
      end
    end

    context "with a bagger profile and bag not valid according to the profile" do
      let(:bag_info) { { "Baz" => "quux" } }

      it_behaves_like "an invalid item", /Foo.*required/
    end
  end
end
