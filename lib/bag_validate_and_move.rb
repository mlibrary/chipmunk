require "package_move"
require "package_validation"
require "chipmunk/bag/validator"
require "chipmunk/sequence"

class BagValidateAndMove
  # inject the validator and mover and the actual validator thingy
  def initialize(queue_item, dest_volume = "bag:1",
                 validation: nil,
                 move: nil)
    @queue_item  = queue_item
    @dest_volume = dest_volume
    @validation  = validation || default_validation
    @move = move || default_move
  end

  def call
    # TODO: capture exceptions and reraise
    status = Chipmunk::Sequence.do([
      validation,
      move
    ])
    if status.success?
      queue_item.record_successful_move(storage_volume: dest_volume)
    else
      queue_item.fail!(status.errors)
    end
  end

  private

  attr_reader :queue_item, :dest_volume
  attr_reader :validation, :move

  def default_validation
    PackageValidation.new(
      Chipmunk::Bag::Validator.new(
        queue_item.package,
        [],
        Services.packages.find(
          id: queue_item.package.bag_id,
          volume: queue_item.package.storage_volume
        )
      )
    )
  end

  def default_move
    PackageMove.new(
      queue_item.package.bag_id,
      queue_item.package.storage_volume,
      dest_volume
    )
  end

end
