# frozen_string_literal: true

require "rails_helper"
require "bag_validate_and_move"

RSpec.describe BagValidateAndMove do
  let(:queue_item) { double("QueueItem") }
  let(:validation) { double("validatebag") }
  let(:move)       { double("movebag") }

  subject(:operation) do
    described_class.new(queue_item, "dest-volume",
                        validation: validation, move: move)
  end

  context "with a valid bag" do
    before do
      allow(validation).to receive(:call).and_return(Chipmunk::Status.success)
      allow(move).to receive(:call).and_return(Chipmunk::Status.success)
      allow(queue_item).to receive(:record_successful_move)
    end

    it "validates the bag" do
      expect(validation).to receive(:call)
      operation.call
    end

    it "moves the bag" do
      expect(move).to receive(:call)
      operation.call
    end

    it "updates the queue item" do
      expect(queue_item).to receive(:record_successful_move).with(storage_volume: "dest-volume")
      operation.call
    end
  end

  context "with an invalid bag" do
    before do
      allow(validation).to receive(:call).and_return(Chipmunk::Status.failure(["validation error"]))
      allow(queue_item).to receive(:fail!)
    end

    it "does not move the bag" do
      expect(move).not_to receive(:call)
      operation.call
    end

    it "fails the queue item" do
      expect(queue_item).to receive(:fail!).with(["validation error"])
      operation.call
    end
  end

  context "when a bag fails to move" do
    before do
      allow(validation).to receive(:call).and_return(Chipmunk::Status.success)
      allow(move).to receive(:call).and_return(Chipmunk::Status.failure(["move error"]))
    end

    it "fails the queue item" do
      expect(queue_item).to receive(:fail!).with(["move error"])
      operation.call
    end
  end
end
