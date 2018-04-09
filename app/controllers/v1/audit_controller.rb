# frozen_string_literal: true

module V1
  class AuditController < ApplicationController
    def index
      authorize :audit
    end

    def create
      authorize :audit
      Package.all.each do |package|
        FixityCheckJob.perform_later(package, current_user)
      end
    end
  end
end
