# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :bag, class_name: 'Package', foreign_key: 'bag_id'
  belongs_to :user

  scope :bag, ->(bag_id) { joins(:bag).where("bags.bag_id = :bag_id or external_id = :bag_id", bag_id: bag_id) if bag_id }
end
