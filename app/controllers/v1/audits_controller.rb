# frozen_string_literal: true

module V1
  class AuditsController < ApplicationController
    def index
      authorize Audit
      @audits = policy_scope(Audit).map { |audit| AuditPresenter.new(audit) }
    end

    def show
      @audit = AuditPresenter.new(Audit.find(params[:id]).tap { |a| authorize(a) })
    end

    def create
      authorize Audit
      count = 0

      Package.stored.each do |package|
        FixityCheckJob.perform_later(package, current_user)
        count += 1
      end

      Audit.create(user: current_user, packages: count)
    end
  end
end
