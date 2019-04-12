# frozen_string_literal: true

class AuditFixityCheckJob < ApplicationJob
  queue_as :default

  def perform(package:, user:, audit:, **kwargs)
    @package = package
    @user = user
    @audit = audit

    save_event(*validate_bag(**kwargs))
  end

  # TODO: This should just receive a bag.
  def validate_bag(storage: Services.storage, bag: storage.for(package), mailer: AuditMailer)
    begin
      if bag.valid?
        outcome = "success"
        detail = nil
      else
        outcome = "failure"
        detail = bag.errors.full_messages.join("\n")
        mailer.failure(emails: [audit.user.email], package: package, error: detail).deliver_now
      end
    rescue RuntimeError => e
      outcome = "failure"
      detail = e.to_s
      mailer.failure(emails: [audit.user.email], package: package, error: detail).deliver_now
    end

    [outcome, detail]
  end

  def save_event(outcome, detail)
    Event.create(
      package: package,
      user: user,
      audit: audit,
      event_type: "fixity check",
      outcome: outcome,
      detail: detail
    )
  end

  private

  attr_reader :package, :user, :audit

end
