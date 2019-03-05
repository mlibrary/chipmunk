# frozen_string_literal: true

module AuthSteps
  step "I am a valid API user with username :username" do |username|
    key = Keycard::ApiKey.new
    @user = Fabricate(:user, username: username, api_key_digest: key.digest)
    header "Authorization", "Token token=#{key.to_s}"
  end
end

RSpec.configure {|config| config.include AuthSteps }
