module Chipmunk

  # The result of a validation attempt
  class ValidationResult

    def initialize(errors)
      @errors = errors.compact
      @errors.freeze
    end

    # @return [Array<String>]
    attr_reader :errors

    # @return [Boolean]
    def valid?
      errors.empty?
    end
  end

end
