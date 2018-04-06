# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :package
  belongs_to :user

  scope :package, ->(bag_id) { joins(:package).where("bag_id = :bag_id or external_id = :bag_id", bag_id: bag_id) if bag_id }
end
