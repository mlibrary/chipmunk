# frozen_string_literal: true

module AuthSteps
  step "I am a :content_type collection manager with username :username" do |content_type, username|
    key = Keycard::DigestKey.new
    @user = Fabricate(:user, username: username, api_key_digest: key.digest)
    header "Authorization", "Token token=#{key}"

    Services.checkpoint.grant!(@user,
                               Checkpoint::Credential::Role.new('content_manager'),
                               Checkpoint::Resource::AllOfType.new(content_type))
  end
end

RSpec.configure do |config|
  config.include AuthSteps
  config.after(:each, type: :feature) do
    Checkpoint::DB.db[:grants].delete
  end
end
