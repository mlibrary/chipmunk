# frozen_string_literal: true

Fabricator(:event) do
  bag { Fabricate(:bag) }
  user { Fabricate(:user) }
  outcome { Faker::Lorem.word }
  event_type { Faker::Lorem.word }
  detail { Faker::Lorem.sentence }
end
