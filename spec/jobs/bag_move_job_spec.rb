# frozen_string_literal: true

require "rails_helper"

RSpec.describe BagMoveJob do
  let(:queue_item) { Fabricate(:queue_item) }
  let(:package) { queue_item.package }

  describe "#perform" do
    let(:bag) { double(:bag, path: "/uploaded/bag") }

    before(:each) do
      allow(Services.validation).to receive(:validate).with(package).and_return(validation_result)
      allow(Services.incoming_storage).to receive(:for).with(package).and_return(bag)
      allow(Services.storage).to receive(:write).with(package, bag) do |pkg, _bag|
        pkg.storage_volume = "bags"
        pkg.storage_path = "/storage/path/to/#{pkg.bag_id}"
      end
    end

    context "when the package is valid" do
      subject(:run_job) { described_class.perform_now(queue_item) }
      let(:validation_result) { double(:validation_result, errors: [], valid?: true) }

      it "moves the bag" do
        expect(Services.storage).to receive(:write)
        run_job
      end

      it "updates the queue_item to status :done" do
        run_job
        expect(queue_item.status).to eql("done")
      end

      # TODO: Make sure that the destination volume is set properly, not literally; see PFDR-185
      it "sets the package storage_volume to root" do
        run_job
        expect(queue_item.package.storage_volume).to eql("bags")
      end

      context "but the move fails" do
        before(:each) do
          allow(Services.storage).to receive(:write).with(package, bag).and_raise "test move failed"
        end

        it "re-raises the exception" do
          expect { run_job }.to raise_error(/test move failed/)
        end

        it "updates the queue_item to status 'failed'" do
          run_job rescue StandardError
          expect(queue_item.status).to eql("failed")
        end

        it "records the error in the queue_item" do
          run_job rescue StandardError
          expect(queue_item.error).to match(/test move failed/)
        end
      end
    end

    context "when the package is invalid" do
      subject(:run_job) { described_class.perform_now(queue_item) }
      let(:validation_result) { double(valid?: false, errors: ["my error"]) }

      it "does not move the bag" do
        expect(Services.storage).not_to receive(:write)
        run_job
      end

      it "updates the queue_item to status 'failed'" do
        run_job
        expect(queue_item.status).to eql("failed")
      end

      it "records the validation error" do
        run_job
        expect(queue_item.error).to match(/my error/)
      end
    end

  end
end
