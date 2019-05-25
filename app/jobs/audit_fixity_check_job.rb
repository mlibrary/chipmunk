# frozen_string_literal: true

class AuditFixityCheckJob < ApplicationJob
  queue_as :default

  # TODO: Taking a bag as `storage` here is a testing concession; this should
  # be cleaned up such that the package and its storage are not separately
  # passed. We also need a better naming distinction between the artifact and
  # the storage of it. That may fall out of the other refactoring.
  def perform(
    package:,
    user:,
    audit:,
    storage: Services.storage.for(package),
    mailer: AuditMailer
  )
    @package = package
    @user = user
    @audit = audit
    @mailer = mailer
    @storage = storage

    save_event(*validate)
  end

  private

  def validate
    begin
      if storage.valid?
        outcome = "success"
        detail = nil
      else
        outcome = "failure"
        detail = storage.errors.full_messages.join("\n")
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

  attr_reader :package, :user, :audit, :mailer, :storage

end
