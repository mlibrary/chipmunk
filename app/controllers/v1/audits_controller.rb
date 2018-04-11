module V1
  class AuditsController < ApplicationController
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
