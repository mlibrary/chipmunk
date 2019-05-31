# frozen_string_literal: true

# Require this helper in tests that need to use the Checkpoint database.
# Also remember to tag the example groups with the policy type so each
# one is wrapped in a transaction that rolls back to handle cleanup.

require_relative "spec_helper"
require "checkpoint"

unless Checkpoint::DB.connected?
  if Checkpoint::DB.conn_opts.empty?
    Checkpoint::DB.connect!(db: Sequel.sqlite)
    Checkpoint::DB.migrate!
  end
end
Checkpoint::DB.initialize!
Checkpoint::DB[:grants].truncate

RSpec.configure do |config|
  config.around(:each, checkpoint_transaction: true) do |example|
    Checkpoint::DB.db.transaction(rollback: :always, auto_savepoint: true) do
      example.run
    end
  end
end
