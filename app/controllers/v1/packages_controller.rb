# frozen_string_literal: true

require "request_builder"
require "package_file_getter"

module V1
  class PackagesController < ResourceController
    # GET /packages
    def index
      policy = collection_policy.new(current_user)
      policy.authorize! :index?

      @packages = policy.resolve
    end

    # GET /packages/1
    # GET /packages/39015012345678
    def show
      resource_policy.new(current_user, package).authorize! :show?
    end

    def sendfile
      resource_policy.new(current_user, package).authorize! :show?
      send_file(*PackageFileGetter.new(package).sendfile(params[:file]))
    end

    # POST /v1/requests
    def create
      collection_policy.new(current_user).authorize! :create?
      status, @request_record = RequestBuilder.new
        .create(create_params.merge(user: current_user))
      case status
      when :duplicate
        head 303, location: v1_request_path(@request_record)
      when :created
        head 201, location: v1_request_path(@request_record)
      when :invalid
        render json: @request_record.errors, status: :unprocessable_entity
      end
    end

    private

    def collection_policy
      @collection_policy ||= PackagesPolicy
    end

    def resource_policy
      @resource_policy ||= PackagePolicy
    end

    def package
      @package ||= Package.find_by_bag_id(params[:bag_id])
      @package ||= Package.find_by_external_id!(params[:bag_id])
    end

    def create_params
      params.permit([:bag_id, :external_id, :content_type])
        .to_h
        .symbolize_keys
    end

  end
end
