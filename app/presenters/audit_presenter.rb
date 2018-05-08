# frozen_string_literal: true

class AuditPresenter
  extend Forwardable

  def initialize(audit, expand: false)
    @audit = audit
    @expand = expand
  end

  def expand?
    @expand
  end

  def successes
    audit.events.where(outcome: "success")
  end

  def failures
    audit.events.where(outcome: "failure")
  end

  def_delegators :audit, :id, :user, :packages, :created_at

  private

  attr_reader :audit
end
