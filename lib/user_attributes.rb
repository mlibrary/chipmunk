# frozen_string_literal: true

# until keycard

require "ostruct"

class UserAttributes < OpenStruct
  def all
    to_h
  end

  def [](attr)
    all[attr]
  end
end
