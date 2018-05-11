# frozen_string_literal: true

class Audit < ApplicationRecord
  belongs_to :user
  has_many :events

  def successful_events
    events.successful
  end

  def failed_events
    events.failed
  end
end
