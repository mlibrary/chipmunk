# frozen_string_literal: true

# env.rb is special. It boots the environment for full runs of Cucumber.
# It is not loaded when run with --dry-run. All of the other files in the
# support directory are automatically loaded on any Cucumber run.
# They cannot depend on env.rb having been loaded.

require "cucumber/rails"
require Rails.root.join("config/application")
require "rack/test"

require "chipmunk"
require "checkpoint"

$LOAD_PATH << File.expand_path("spec")
require "all_support"

ActionController::Base.allow_rescue = false

begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end


# Possible values are :truncation and :transaction
# The :transaction strategy is faster, but might give you threading problems.
# See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
Cucumber::Rails::Database.javascript_strategy = :truncation

unless Checkpoint::DB.connected?
  if Checkpoint::DB.conn_opts.empty?
    Checkpoint::DB.connect!(db: Sequel.sqlite)
    Checkpoint::DB.migrate!
  end
end
Checkpoint::DB.initialize!
Checkpoint::DB[:grants].truncate

Around do |scenario, block|
  Checkpoint::DB.db.transaction(rollback: :always, auto_savepoint: true) do
    block.call
  end
end

module AppHelper
  # Rack-Test expects the app method to return a Rack application
  def app
    Chipmunk::Application
  end
end

# Set the queue adapter to inline so that jobs are run without a backend queue
ApplicationJob.queue_adapter = :inline

World(Rack::Test::Methods, AppHelper)

