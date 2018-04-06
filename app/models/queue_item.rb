# frozen_string_literal: true

class QueueItem < ApplicationRecord

  enum status: {
    pending: 0,
    failed:  1,
    done:    2
  }

  belongs_to :package

  validates :status, presence: true
  validates :package_id, presence: true

  def user
    package.user
  end

end
