# frozen_string_literal: true

module V1
  class AuditsController < ApplicationController
    def index
      policy = AuditsPolicy.new(current_user)
      policy.authorize! :index?
      @audits = policy.resolve.map {|audit| AuditPresenter.new(audit, expand: expand?) }
    end

    def show
      @audit = AuditPresenter.new(Audit.find(params[:id]).tap {|a| AuditPolicy.new(current_user, a).authorize! :show? }, expand: expand?)
    end

    def create
      AuditsPolicy.new(current_user).authorize! :create?

      packages = Package.stored
      audit = Audit.create!(user: current_user, packages: packages.count)
      packages.each do |package|
        AuditFixityCheckJob.perform_later(package: package, user: current_user, audit: audit)
      end
      head 201, location: v1_audit_path(audit)
    end

    private

    def expand?
      ActiveModel::Type::Boolean.new.cast(params.key?(:expand))
    end
  end
end
