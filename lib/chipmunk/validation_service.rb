require_relative "validation_result"

module Chipmunk

  class ValidationService

    # @return [ValidationResult]
    def validate(validatable)
      case validatable
      when Package
        validate_with(validatable, package_validators(validatable))
      else
        ValidationResult.new(["Did not recognize type #{validatable.class}"])
      end
    end

    private

    def validate_with(validatable, validators)
      if incoming_storage.include?(validatable)
        sip = incoming_storage.for(validatable)
        ValidationResult.new(errors(validators, sip))
      else
        return ValidationResult.new(["Could not find an uploaded sip"])
      end
    end

    def package_validators(package)
      [
        Validator::StorageFormat.new(package.storage_format),
        Validator::BagConsistency.new,
        Validator::BagMatchesPackage.new(package),
        Validator::External.new(package),
        Validator::BaggerProfile.new(package)
      ]
    end

    # @param validators [Array<Validator::Validator>]
    # @param validatable [Object] The object being validated, e.g. a Bag
    def errors(validators, validatable)
      validators.reduce([]) do |errors, validator|
        errors + validator.errors(validatable)
      end
    end

    def incoming_storage
      Services.incoming_storage
    end
  end

end
