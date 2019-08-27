require_relative "validator"

module Chipmunk
  module Validator

    # Validate that the bag obeys the spec set by the profile
    class BaggerProfile < Validator

      # @param [Bag::Profile]
      def initialize(profile)
        @profile = profile
      end

      validates "bag on disk meets bagger profile",
        condition: proc {|bag, errors| errors.empty? },
        error: proc {|bag, errors| errors },
        precondition: proc {|bag|
          [].tap {|errors| profile.valid?(bag.bag_info, errors: errors) }
        }

      private

      attr_reader :profile
    end
  end
end
