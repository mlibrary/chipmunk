# frozen_string_literal: true

require "faker"

module ChipmunkFaker
  Internet = Faker::Internet.unique

  def self.user_name
    "#{Internet.user_name}#{rand 9999}"
  end
end
