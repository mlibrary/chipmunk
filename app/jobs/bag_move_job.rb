# frozen_string_literal: true

require "open3"

class BagMoveJob < ApplicationJob

  def perform(queue_item)
    @queue_item = queue_item
    @package = queue_item.package
    @errors = []

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
    package.valid_for_ingest?(errors)
  end

  # TODO: break the connection between the ingest format and storage format
  def move_bag
    FileUtils.mkdir_p(File.dirname(package.dest_path))
    File.rename(package.src_path, package.dest_path)
  end

  def record_success
    queue_item.transaction do
      queue_item.status = :done
      queue_item.save!
      package.storage_location = package.dest_path
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
end
