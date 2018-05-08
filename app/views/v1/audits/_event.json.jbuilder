# frozen_string_literal: true

json.external_id event.package.external_id
json.bag_id event.package.bag_id
json.detail event.detail
json.date event.created_at.to_formatted_s(:default)
