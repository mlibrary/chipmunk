# frozen_string_literal: true

Fabricator(:package, aliases: [:request]) do
  bag_id { SecureRandom.uuid }
  user { Fabricate(:user) }
  external_id { SecureRandom.uuid }
  storage_location { File.join Faker::Lorem.word, Faker::Lorem.word, Faker::Lorem.word }
  content_type { ["digital", "audio"].sample }
end
