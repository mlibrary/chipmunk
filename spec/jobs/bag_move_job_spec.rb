# frozen_string_literal: true

require "rails_helper"

RSpec.describe BagMoveJob do
  let(:queue_item) { Fabricate(:queue_item) }
  let(:package) { queue_item.bag }
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

  let(:chipmunk_info_good) do
    chipmunk_info_db.merge(
      "Metadata-Type"         => "MARC",
      "Metadata-URL"          => "http://what.ever",
      "Metadata-Tagfile"      => "marc.xml"
    )
  end

  class InjectedError < RuntimeError
  end

  describe "#perform" do
    before(:each) do
      allow(File).to receive(:rename).with(src_path, dest_path).and_return true
    end

    context "when the package is valid" do
      subject(:run_job) { described_class.perform_now(queue_item) }

      before(:each) do
        allow(queue_item.package).to receive(:valid_for_ingest?).and_return true
      end

      it "moves the bag" do
        expect(File).to receive(:rename).with(src_path, dest_path)
        run_job
      end

      it "updates the queue_item to status :done" do
        run_job
        expect(queue_item.status).to eql("done")
      end

      # TODO: Make sure that the destination volume is set properly, not literally; see PFDR-185
      it "sets the package storage_volume to root" do
        run_job
        expect(queue_item.package.storage_volume).to eql("root")
      end

      context "but the move fails" do
        before(:each) do
          allow(File).to receive(:rename).with(src_path, dest_path).and_raise InjectedError, "injected error"
        end

        it "re-raises the exception" do
          expect { run_job }.to raise_exception(InjectedError)
        end

        it "updates the queue_item to status 'failed'" do
          begin
            run_job
          rescue InjectedError
          end

          expect(queue_item.status).to eql("failed")
        end

        it "records the error in the queue_item" do
          begin
            run_job
          rescue InjectedError
          end

          expect(queue_item.error).to match(/injected error/)
        end
      end
    end

    context "when the package is invalid" do
      subject(:run_job) { described_class.perform_now(queue_item) }

      before(:each) do
        allow(queue_item.package).to receive(:valid_for_ingest?) do |errors|
          errors << "my error"
          false
        end
      end

      it "does not move the bag" do
        expect(File).not_to receive(:rename).with(src_path, dest_path)
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

      it "does not move the bag" do
        expect(File).not_to receive(:rename).with(src_path, dest_path)
        run_job
      end
    end

    context "when validation raises an exception" do
      subject(:run_job) { described_class.perform_now(queue_item) }

      before(:each) do
        allow(queue_item.package).to receive(:valid_for_ingest?).and_raise("arbitrary failure")
      end

      it "re-raises the exception" do
        expect { run_job }.to raise_exception(/arbitrary failure/)
      end

      it "records the exception" do
        begin
          run_job
        rescue StandardError
        end

        expect(queue_item.error).to match(/arbitrary failure/)
      end

      it "records the stack trace" do
        begin
          run_job
        rescue StandardError
        end

        expect(queue_item.error).to match(__FILE__)
      end
    end
  end
end
