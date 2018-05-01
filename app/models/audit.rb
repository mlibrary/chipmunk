# frozen_string_literal: true

class Audit < ApplicationRecord
  belongs_to :user
  has_many :events
end
