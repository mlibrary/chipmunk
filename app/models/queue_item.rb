# frozen_string_literal: true

class QueueItem < ApplicationRecord

  enum status: {
    pending: 0,
    failed:  1,
    done:    2
  }

  belongs_to :bag, class_name: 'Package', foreign_key: 'bag_id'

  validates :status, presence: true
  validates :bag_id, presence: true

  def user
    bag.user
  end

end
