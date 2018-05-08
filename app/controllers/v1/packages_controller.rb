# frozen_string_literal: true

require "request_builder"

module V1
  class PackagesController < ApplicationController

    # GET /packages
    def index
      @packages = policy_scope(Package)
    end

    # GET /packages/1
    # GET /packages/39015012345678
    def show
      authorize package
    end

    # POST /v1/requests
    def create
      authorize Package
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

    def fixity_check
      authorize package
      FixityCheckJob.perform_later(package: package, user: current_user)
    end

    private

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
