# frozen_string_literal: true

class User < ApplicationRecord

  attr_accessor :identity

  validates :email, presence: true
  validates :admin, inclusion: { in: [true, false] }
  validates :api_key_digest, presence: true
  validates :username, presence: true

  # Assign an API key
  before_create do
    self.api_key_digest = api_key.digest
  end

  def api_key
    @api_key ||= if [nil, 'x'].include?(api_key_digest)
      Keycard::ApiKey.new
    else
      Keycard::ApiKey::Hidden.new
    end
  end

  def known?
    persisted?
  end

  def agent_type
    "user"
  end

  def agent_id
    username
  end

end
