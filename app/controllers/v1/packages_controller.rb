# frozen_string_literal: true

require "request_builder"
require "zip_tricks"

module V1
  class PackagesController < ResourceController
    include ActionController::Live
    include ZipTricks::RailsStreaming

    collection_policy PackagesPolicy
    resource_policy PackagePolicy

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

      # Expose the bag if this is a request for a logical package.
      # Avoid exposing it if this is a request for a logical request.
      if package.stored?
        # TODO: Once the interface of Repository/DiskStorage is sorted out,
        #       use that, rather than going around it.
        @bag = Chipmunk::Bag.__from_package__(package)
      end
    end

    def sendfile
      resource_policy.new(current_user, package).authorize! :show?
      # TODO: Once the interface of Repository/DiskStorage is sorted out,
      #       use that, rather than going around it.
      bag = Chipmunk::Bag.__from_package__(package)
      if bag.includes_data?(params[:file])
        file = bag.data_file!(params[:file])
        send_file(file.to_s, type: file.type, status: 200)
      else
        file_not_found
      end
    end

    def send_package
      resource_policy.new(current_user, package).authorize! :show?

      unless package.stored?
        head 404
        return
      end

      # TODO: Once the interface of Repository/DiskStorage is sorted out,
      #       use that, rather than going around it.
      # Zip Tricks can take only non-directory paths as strings.
      bag = Chipmunk::Bag.__from_package__(package)
      zip_tricks_stream do |zip|
        bag.relative_files.each do |file|
          zip.write_deflated_file(file.to_s) do |sink|
            IO.copy_stream((bag.bag_dir/file).to_s, sink)
          end
        end
      end
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
