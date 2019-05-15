# frozen_string_literal: true

require "rails_helper"

RSpec.describe BagMoveJob do
  let(:queue_item) { 362368 }
  let(:operation) { double(:operation, call: nil) }

  before(:each) do
    allow(BagValidateAndMove).to receive(:new).and_return(operation)
  end

  it "creates a BagValidateAndMove" do
    expect(BagValidateAndMove).to receive(:new).with(queue_item)
    described_class.perform_now(queue_item)
  end

  it "delegates to BagValidateAndMove" do
    expect(operation).to receive(:call)
    described_class.perform_now(queue_item)
  end

end
