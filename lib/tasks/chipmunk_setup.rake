# frozen_string_literal: true

require "fileutils"

namespace :chipmunk do
  def create_paths(app_storage_path, app_upload_user_path, user_upload_path)
    # create rsync point
    FileUtils.mkdir_p(app_storage_path) unless File.exist?(app_storage_path)
    FileUtils.mkdir_p(app_upload_user_path) unless File.exist?(app_upload_user_path)
    FileUtils.symlink(app_upload_user_path, user_upload_path) unless File.exist?(user_upload_path)
  end

  def write_upload_config(config_path, app_storage_path, app_upload_path, user_upload_path)
    # update upload.yml
    config = {}
    config = YAML.load_file(config_path) if File.exist?(config_path)
    config["upload"] ||= {}
    config["upload"]["rsync_point"] = "localhost:#{user_upload_path}"
    config["upload"]["storage_path"] = app_storage_path
    config["upload"]["upload_path"] = app_upload_path
    YAML.dump(config, File.new(config_path, "w"))
    puts "Storage locations for #{Rails.env}:"
    puts YAML.dump(config["upload"])
    puts
  end

  def client_config(username)
    # find/create user
    user = User.find_by_username(username)
    unless user
      user = User.create(username: username, email: "nobody@nowhere")
      user.save
    end
    puts "User API key for #{user.username}: #{user.api_key}"
  end

  task setup: :environment do
    username = ENV["USER"]
    app_storage_path = "#{Rails.root}/repo/storage"
    app_upload_path = "#{Rails.root}/repo/incoming"
    user_upload_path = "#{Rails.root}/incoming"
    config_path = "#{Rails.root}/config/settings/#{Rails.env}.local.yml"

    create_paths(app_storage_path, "#{app_upload_path}/#{username}", user_upload_path)
    write_upload_config(config_path, app_storage_path, app_upload_path, user_upload_path)
    puts "Ensure #{username} can rsync via ssh with write access to:"
    puts "  localhost:#{user_upload_path}"
    puts

    client_config(username)
  end
end
