require "checkpoint"

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

require Rails.root.join('config/application')
require 'rack/test'

module AppHelper
  # Rack-Test expects the app method to return a Rack application
  def app
    Chipmunk::Application
  end
end

World(Rack::Test::Methods, AppHelper)
