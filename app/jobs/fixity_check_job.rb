# frozen_string_literal: true

require "chipmunk_bag_validator"

class FixityCheckJob < ApplicationJob
  queue_as :default

  def perform(package, user, bag: ChipmunkBag.new(db_bag.src_path))
    begin
      if bag.valid?
        outcome = "success"
        detail = nil
      else
        outcome = "failure"
        detail = bag.errors.full_messages.join("\n")
      end
    rescue RuntimeError => e
      outcome = "failure"
      detail = e.to_s
    end

    Event.create(bag: package, user: user, event_type: "fixity check", outcome: outcome, detail: detail)
  end

end
