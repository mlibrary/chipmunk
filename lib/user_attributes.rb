# until keycard

require 'ostruct'

class UserAttributes < OpenStruct
  def all
    self.to_h
  end
end
