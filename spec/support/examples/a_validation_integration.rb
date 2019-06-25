# frozen_string_literal: true

require "rails_helper"
require "chipmunk"
require "fileutils"

# @param content_type [String] The content type to use when constructing Bags.
#   Also used when finding fixtures: they should be placed under
#   under spec/support/fixtures/content_type/{good,bad}
# @param external_id [String] The external identifier that should be used when
#   constructing Bags.
# @param expected_error [Regexp] A Regexp that the expected output from
#   validating spec/support/fixtures/content_type/bad should match.
RSpec.shared_examples "a validation integration" do
  def fixture(*args)
    File.join(Rails.application.root, "spec", "support", "fixtures", *args)
  end

  around(:each) do |example|
    old_incoming_storage = Services.incoming_storage
    Services.register(:incoming_storage) do
      Chipmunk::IncomingStorage.new(
        volume: Chipmunk::Volume.new(name: "incoming", package_type: Chipmunk::Bag, root_path: fixture(content_type)),
        paths: Chipmunk::IncomingStorage::UserPathBuilder.new("/"),
        links: Chipmunk::IncomingStorage::IdPathBuilder.new("/this/does/not/get/used")
      )
    end

    example.run

    Services.register(:incoming_storage) { old_incoming_storage}
  end

  before(:each) do
    allow(Services.storage).to receive(:write).with(package, anything).and_return true
  end

  # for known upload location under fixtures/video
  let(:upload_user) { Fabricate(:user, username: "upload") }
  let(:queue_item) { Fabricate(:queue_item, package: package) }

  subject(:perform_bag_move_job) { BagMoveJob.perform_now(queue_item) }

  def package_with_id(bag_id)
    Fabricate(:package, content_type: content_type,
              bag_id: bag_id,
              external_id: external_id,
              user: upload_user)
  end

  context "with a valid bag" do
    let(:package) { package_with_id("goodbag") }

    it "completes the queue item and moves it to the destination" do
      allow(Services.storage).to receive(:write).with(package, anything) do |package, _bag|
        package.storage_volume = "test"
        package.storage_path = "/stored/path"
        true
      end
      perform_bag_move_job
      expect(queue_item.status).to eql("done")
      expect(queue_item.package.storage_volume).to eql("test")
      expect(queue_item.package.storage_path).to eql("/stored/path")
    end
  end

  context "with an invalid bag" do
    let(:package) { package_with_id("badbag") }

    it "reports the error and does not move the bag to storage" do
      perform_bag_move_job
      expect(queue_item.error).to match(expected_error)
      expect(queue_item.package.storage_volume).to be_nil
      expect(queue_item.package.storage_path).to be_nil
    end
  end

  context "with a nonexistent bag" do
    let(:package) { package_with_id("deleteme") }

    before(:each) do
      allow(Services.incoming_storage).to receive(:include?).and_return(false)
    end

    it "does not store the bag" do
      expect(Services.storage).not_to receive(:write)
      perform_bag_move_job
    end
  end
end
