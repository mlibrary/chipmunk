# frozen_string_literal: true

require "chipmunk_bag_validator"

class FixityCheckJob < ApplicationJob
  queue_as :default

  def perform(package:, user:, audit: nil, bag: ChipmunkBag.new(package.storage_location), mailer: AuditMailer)
    begin
      if bag.valid?
        outcome = "success"
        detail = nil
      else
        outcome = "failure"
        detail = bag.errors.full_messages.join("\n")
        mailer.failure(audit: audit, package: package, error: detail).deliver_now
      end
    rescue RuntimeError => e
      outcome = "failure"
      detail = e.to_s
      mailer.failure(audit: audit, package: package, error: detail).deliver_now
    end

    Event.create(package: package, user: user, audit: audit, event_type: "fixity check", outcome: outcome, detail: detail)
  end

end
