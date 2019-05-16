# frozen_string_literal: true

require "rails_helper"
require "bag_validate_and_move"

RSpec.describe BagValidateAndMove do
  let(:queue_item) { Fabricate(:queue_item) }
  let(:bag) { double(:bag) }
  let(:validator) { double(:validator) }
  let(:bag_validation) { double(:bag_validation) }
  let(:bag_move) { double(:bag_move) }

  subject(:operation) { described_class.new(queue_item) }

  before(:each) do
    allow(Services.packages).to receive(:find)
      .with(id: queue_item.package.bag_id, volume: queue_item.package.storage_volume)
      .and_return(bag)

    allow(Chipmunk::Bag::Validator).to receive(:new)
      .with(queue_item.package, [], bag)
      .and_return(validator)

    allow(BagValidation).to receive(:new) .and_return(bag_validation)
    allow(bag_validation).to receive(:perform).and_yield

    allow(BagMove).to receive(:new).and_return(bag_move)
    allow(bag_move).to receive(:perform)
  end

  it "validates the bag" do
    expect(bag_validation).to receive(:perform)
    operation.perform
  end

  it "moves the bag" do
    expect(bag_move).to receive(:perform)
    operation.perform
  end

end

