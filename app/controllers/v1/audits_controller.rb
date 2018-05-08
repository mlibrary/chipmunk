# frozen_string_literal: true

module V1
  class AuditsController < ApplicationController
    def index
      authorize Audit
      @audits = policy_scope(Audit).map {|audit| AuditPresenter.new(audit, expand: expand?) }
    end

    def show
      @audit = AuditPresenter.new(Audit.find(params[:id]).tap {|a| authorize(a) }, expand: expand?)
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

    private

    def expand?
      ActiveModel::Type::Boolean.new.cast(params.key?(:expand))
    end
  end
end
