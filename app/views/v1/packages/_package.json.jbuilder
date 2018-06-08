# frozen_string_literal: true

json.bag_id package.bag_id
json.user package.user.username
json.content_type package.content_type
json.external_id package.external_id
json.upload_link package.upload_link
if @current_user&.admin?
  json.storage_location package.storage_location
end
json.stored package.stored?
json.created_at package.created_at.to_formatted_s(:default)
json.updated_at package.updated_at.to_formatted_s(:default)
if expand and package.stored?
  json.files PackageFileGetter.new(package).files
end
