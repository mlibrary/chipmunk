require "fileutils"

Before do
  FileUtils.mkdir_p Chipmunk.config.upload.upload_path
end

After do
  FileUtils.rm_rf Chipmunk.config.upload.upload_path
end
