# frozen_string_literal: true

module Chipmunk

  # A generic wrapper over the result of some operation.
  class Status

    def self.success(output = "")
      new(true, output, [])
    end

    def self.failure(errors = [])
      new(false, "", errors)
    end

    # @param success [Boolean]
    # @param output [String]
    # @param error [String]
    def initialize(success, output = "", errors = [])
      @success = success
      @output = output
      @errors = errors
    end

    # Any errors reported
    # @return [String]
    attr_reader :errors
    attr_reader :output

    # @return [Boolean]
    def success?
      @success
    end

    def eql?(other)
      success? == other.success? &&
        output == other.output &&
        errors == other.errors
    end
    alias_method :==, :eql?
  end

end
