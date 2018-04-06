# frozen_string_literal: true

Fabricator(:event) do
  package { Fabricate(:package) }
  user { Fabricate(:user) }
  outcome { Faker::Lorem.word }
  event_type { Faker::Lorem.word }
  detail { Faker::Lorem.sentence }
end
