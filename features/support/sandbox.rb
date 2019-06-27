# frozen_string_literal: true

require "fileutils"

Before do
  FileUtils.mkdir_p Chipmunk.config.upload.storage_path
  FileUtils.mkdir_p Chipmunk.config.upload.upload_path
end

After do
  FileUtils.rm_rf Chipmunk.config.upload.storage_path
  FileUtils.rm_rf Chipmunk.config.upload.upload_path
end
