# frozen_string_literal: true

# require "queue_item_builder"

module V1
  class QueueItemsController < ResourceController
    collection_policy QueueItemsPolicy
    resource_policy QueueItemPolicy

    attr_writer :bag_move_job

    # GET /v1/queue
    def index
      policy = collection_policy.new(current_user)
      policy.authorize! :index?

      @queue_items = policy.resolve.for_package(params[:package])
    end

    # GET /v1/queue/:id
    def show
      @queue_item = QueueItem.find(params[:id])
      resource_policy.new(current_user, @queue_item).authorize! :show?
      render template: "v1/queue_items/show", status: 200
    end

    # POST /v1/requests/:bag_id/complete
    def create
      descriptor = Package.find_by_bag_id!(params[:bag_id])

      if duplicate = QueueItem.where(package: descriptor, status: [:pending, :done]).first
        head 303, location: v1_queue_item_path(duplicate)
      else
        case create_qitem(descriptor)
        when :created
          head 201, location: v1_queue_item_path(@queue_item)
        when :invalid
          render json: @queue_item.errors, status: :unprocessable_entity
        else
          raise "Unexpected status: #{status.inspect} for queue item #{@queue_item.id}"
        end
      end
    end

    private

    def bag_move_job
      @bag_move_job ||= BagMoveJob
    end

    def create_qitem(descriptor)
      @queue_item = new_qitem(descriptor)
      save_qitem(@queue_item)
    end

    def new_qitem(descriptor)
      collection_policy.new(current_user).authorize! :new?

      QueueItem.new(package: descriptor)
    end

    def save_qitem(queue_item)
      resource_policy.new(current_user,queue_item).authorize! :create?

      if queue_item.valid?
        queue_item.save!
        bag_move_job.perform_later(queue_item)
        return :created
      else
        return :invalid
      end
    end
  end
end
