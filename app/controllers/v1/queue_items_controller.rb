# frozen_string_literal: true

require "queue_item_builder"

module V1
  class QueueItemsController < ResourceController
    collection_policy QueueItemsPolicy
    resource_policy QueueItemPolicy

    # GET /v1/queue
    def index
      policy = collection_policy.new(current_user)
      policy.authorize! :index?

      @queue_items = policy.resolve
    end

    # GET /v1/queue/:id
    def show
      @queue_item = QueueItem.find(params[:id])
      resource_policy.new(current_user, @queue_item).authorize! :show?
      render template: "v1/queue_items/show", status: 200
    end

    # POST /v1/requests/:bag_id/complete
    def create
      request = Package.find_by_bag_id!(params[:bag_id])
      authorize_create!(request)
      status, @queue_item = QueueItemBuilder.new.create(request)
      case status
      when :duplicate
        head 303, location: v1_queue_item_path(@queue_item)
      when :created
        head 201, location: v1_queue_item_path(@queue_item)
      when :invalid
        render json: @queue_item.errors, status: :unprocessable_entity
      else
        raise [status, @queue_item]
      end
    end

    private

    def authorize_create!(request)
      policy = collection_policy.new(current_user)
      unless policy.create?(request)
        raise NotAuthorizedError, "not allowed to create? this QueueItem for #{params[:bag_id]}"
      end
    end

  end

end
