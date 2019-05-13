# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :package
  belongs_to :user
  belongs_to :audit, optional: true

  scope :package, ->(bag_id) { joins(:package).where("bag_id = :bag_id or external_id = :bag_id", bag_id: bag_id) if bag_id }
  scope :successful, -> { where(outcome: "success") }
  scope :failed, -> { where(outcome: "failure") }
  scope :owned, ->(user_id) { joins(:package).where(packages: { user_id: user_id }) if user_id }

  # FIXME PFDR-168 untested
  scope :with_type, ->(content_type) { joins(:package).with_type(content_type) }
  scope :with_type_and_id, ->(content_type, id) { joins(:package).with_type_and_id(content_type, id) }
end
