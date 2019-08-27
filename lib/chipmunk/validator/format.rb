require_relative "validator"

module Chipmunk
  module Validator
    class Format < Validator
      def initialize(format)
        @format = format
      end

      validates "the format matches",
        condition: proc {|sip| sip.format == format },
        error: proc {|sip| "SIP #{sip.identifier} has invalid format: #{sip.format}" }

      private

      attr_reader :format
    end
  end
end
