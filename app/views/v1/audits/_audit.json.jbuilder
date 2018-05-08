# frozen_string_literal: true

json.id audit.id
if audit.expand?
  json.successes audit.successes, partial: "v1/audits/event", as: :event
  json.failures audit.failures, partial: "v1/audits/event", as: :event
else
  json.successes audit.successes.count
  json.failures audit.failures.count
end
json.packages audit.packages
json.user audit.user.username
json.date audit.created_at.to_formatted_s(:default)
