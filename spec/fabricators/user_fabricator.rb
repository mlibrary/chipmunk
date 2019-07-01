# frozen_string_literal: true

Fabricator(:user) do
  email { ChipmunkFaker::Internet.email }
  username { ChipmunkFaker.user_name }
  api_key_digest { Faker::Crypto.sha256 }
  admin false
end
