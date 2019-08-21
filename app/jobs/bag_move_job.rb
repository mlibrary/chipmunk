# frozen_string_literal: true

require "open3"

class BagMoveJob < ApplicationJob

  def perform(queue_item, incoming_storage: Services.incoming_storage, package_storage: Services.storage)
    @queue_item = queue_item
    @package = queue_item.package
    @errors = []
    @incoming_storage = incoming_storage
    @package_storage = package_storage

    # TODO
    #  - if all validation succeeds:
    #    - start a transaction that updates the request to complete
    #    - move the bag into place
    #    - success: commit the transaction
    #    - failure (exception) - transaction automatically rolls back

    ingest! or record_failure
  end

  private

  def ingest!
    validate and move_bag and record_success
  rescue StandardError => error
    log_exception(error)
  end

  def validate
    if package.stored?
      errors << "Package #{package} is already stored"
    end
    !package.stored? && package.valid_for_ingest?(errors)
  end

  def move_bag
    source = incoming_storage.for(package)
    package_storage.write(package, source)
  end

  def record_success
    queue_item.transaction do
      queue_item.status = :done
      queue_item.save!
      package.save!
    end
  end

  def record_failure
    queue_item.transaction do
      queue_item.error = errors.join("\n\n")
      queue_item.status = :failed
      queue_item.save!
    end
  end

  def log_exception(exception)
    errors << "#{exception.backtrace.first}: #{exception.message} (#{exception.class})"
    errors << exception.backtrace.drop(1).map {|s| "\t#{s}" }
    record_failure
    raise exception
  end

  attr_accessor :queue_item, :package, :errors
  attr_accessor :incoming_storage, :package_storage
end
