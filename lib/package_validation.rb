# frozen_string_literal: true

require "chipmunk/status"

class PackageValidation

  def initialize(validator)
    @validator = validator
  end

  def call
    if validator.valid?
      Chipmunk::Status.success
    else
      Chipmunk::Status.failure(validator.errors)
    end
  end

  private

  attr_accessor :validator

end
