# frozen_string_literal: true

Fabricator(:user) do
  email { Faker::Internet.email }
  username { Faker::Internet.user_name }
  api_key_digest { Faker::Crypto.sha256 }
  admin false
end
