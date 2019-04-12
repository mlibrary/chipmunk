# frozen_string_literal: true

class User < ApplicationRecord

  attr_accessor :identity

  validates :email, presence: true
  validates :admin, inclusion: { in: [true, false] }
  validates :api_key_digest, presence: true
  validates :username, presence: true

  # Assign an API key
  after_initialize :add_key, on: :create

  def api_key
    @api_key ||= if [nil, "x"].include?(api_key_digest)
      Keycard::DigestKey.new
    else
      Keycard::DigestKey.new(api_key_digest)
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

  private

  def add_key
    self.api_key_digest = api_key.digest
  end

end
