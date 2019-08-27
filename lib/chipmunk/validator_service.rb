module Chipmunk

  # Retrieve validators needed to finish a deposit
  # I suppose there's no point in returning validators when we could just
  # return the validation result. Sigh.
  #
  # The motivation for this is it lets us remove validation checks out of
  # the ingest process and that process's dependencies. This should let us
  # simplify Package, Deposit, BagMoveJob, and FinishDeposit.
  class ValidatorService
    # other names: IngestValidationService

    def for(validatable) # deposit, package

    end

    # TODO: rename
    def for_package(package)
      [
        Validator::BagConsistency.new,
        Validator::BagMatchesPackage.new(package),
      ].concat(bagger_profile_validator_for_package(package))
        .concat(external_validator_for_package(package))
    end

    def external_validator_for_package(package)
      ext_cmd = Rails.application.config.validation["external"][package.content_type.to_s]
      if ext_cmd
        path = Services.incoming_storage.for(package).path
        cmd = [ext_cmd, package.external_id, path].join(" ")
        [Validator::External.new(cmd)]
      else
        []
      end
    end

    def bagger_profile_validator_for_package(package)
      uri = Rails.application.config.validation["bagger_profile"][package.content_type.to_s]
      if uri
        [Validator::BaggerProfile.new(Bag::Profile.new(uri))]
      else
        []
      end

    end

    # TODO: rename, reconsider
    def errors_for_package(package, validatable)
      for_package(package).reduce([]) do |errors, validator|
        errors + validator.errors(validatable)
      end
    end

  end
end
