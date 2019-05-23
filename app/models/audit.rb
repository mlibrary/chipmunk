# frozen_string_literal: true

class Audit < ApplicationRecord
  belongs_to :user
  has_many :events

  def self.resource_types
    ["Audit"]
  end
end
