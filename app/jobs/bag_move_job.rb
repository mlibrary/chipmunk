# frozen_string_literal: true

require "bag_validate_and_move"

class BagMoveJob < ApplicationJob
  def perform(queue_item)
    BagValidateAndMove.new(queue_item).call
  end
end
