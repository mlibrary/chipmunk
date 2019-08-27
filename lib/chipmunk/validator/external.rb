require_relative "validator"
require "open3"

module Chipmunk
  module Validator

    # Validate that some external validation passes
    class External< Validator

      # @param command [String] The fully specified command, including any reference
      #   to the object to be validated.
      def initialize(command)
        @command = command
      end

      validates "the object passes external validation",
        only_if: proc {|validatable| validatable.valid? },
        precondition: proc { Open3.capture3(command) },
        condition: proc {|_, _, _, status| status.exitstatus.zero? },
        error: proc {|_, _, stderr, _|  "Error validating content\n" + stderr }

      private

      attr_reader :command
    end

  end
end
