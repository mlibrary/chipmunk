# frozen_string_literal: true

class QueueItemBuilder

  def initialize; end

  def build(descriptor)
    @descriptor = descriptor
    @queue_item = QueueItem.new(package: descriptor)
  end

  def save
    duplicate = QueueItem.where(package: descriptor, status: [:pending, :done]).first
    unless duplicate.nil?
      return :duplicate, duplicate
    end

    if queue_item.valid?
      queue_item.save!
      BagMoveJob.perform_later(queue_item)
      return :created, queue_item
    else
      return :invalid, queue_item
    end
  end

  def create(descriptor)
    build(descriptor)
    save
  end

  private

  attr_reader :descriptor, :queue_item

end
