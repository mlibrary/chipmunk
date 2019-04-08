# frozen_string_literal: true

class QueueItem < ApplicationRecord

  scope :owned, ->(user_id) { joins(:package).where(packages: { user_id: user_id }) if user_id }

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

  scope :for_package, ->(package_id) { where(package_id: package_id) unless package_id.blank? }

end
