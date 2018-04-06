# frozen_string_literal: true

json.id event.id
json.type event.event_type
json.executor event.user.username
json.outcome event.outcome
json.detail event.detail
json.date event.created_at.to_formatted_s(:default)
