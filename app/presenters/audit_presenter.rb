class AuditPresenter
  extend Forwardable

  def initialize(audit)
    @audit = audit
  end

  def successes
    audit.events.where(outcome: 'success').count
  end

  def failures
    audit.events.where(outcome: 'failure').count
  end

  def_delegators :audit, :user, :packages, :created_at

  private

  attr_reader :audit
end
