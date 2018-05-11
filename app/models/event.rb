# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :package
  belongs_to :user
  belongs_to :audit, optional: true

  scope :package, ->(bag_id) { joins(:package).where("bag_id = :bag_id or external_id = :bag_id", bag_id: bag_id) if bag_id }
  scope :successful, -> { where(outcome: "success") }
  scope :failed, -> { where(outcome: "failure") }
end
