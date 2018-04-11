# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :bag
  belongs_to :user

  scope :bag, ->(bag_id) { joins(:bag).where("bags.bag_id = :bag_id or external_id = :bag_id", bag_id: bag_id) if bag_id }
end
