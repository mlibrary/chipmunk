# frozen_string_literal: true

require "checkpoint_helper"

module AuthSteps
  step "I am a :content_type content manager with username :username" do |content_type, username|
    key = Keycard::DigestKey.new
    @user = Fabricate(:user, username: username, api_key_digest: key.digest)
    header "Authorization", "Token token=#{key}"

    Services.checkpoint.grant!(@user,
      Checkpoint::Credential::Role.new("content_manager"),
      Checkpoint::Resource::AllOfType.new(content_type))
  end
end

RSpec.configure do |config|
  config.include AuthSteps
end
