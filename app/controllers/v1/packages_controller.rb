# frozen_string_literal: true

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
        @bag = Services.storage.for(package)
      end
    end

    def sendfile
      resource_policy.new(current_user, package).authorize! :show?
      bag = Services.storage.for(package)
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

      # Zip Tricks can take only non-directory paths as strings.
      bag = Services.storage.for(package)
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
      duplicate = Package.find_by_bag_id(params[:bag_id])
      duplicate ||= Package.find_by_external_id(params[:external_id])

      if duplicate
        resource_policy.new(current_user,duplicate).authorize! :show?
        head 303, location: v1_package_path(duplicate)
      else
        case create_package(create_params)
        when :created
          head 201, location: v1_package_path(@package)
        when :invalid
          render json: @package.errors, status: :unprocessable_entity
        end
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

    def create_package(create_params)
      @package = new_descriptor(**create_params)
      save_descriptor(@package)
    end

    def new_descriptor(bag_id:, external_id:, content_type:)
      collection_policy.new(current_user).authorize! :new?

      Package.new(
        bag_id: bag_id,
        external_id: external_id,
        content_type: content_type,
        user: current_user
      )
    end

    def save_descriptor(descriptor)
      resource_policy.new(current_user,descriptor).authorize! :create?

      if descriptor.valid?
        descriptor.save!
        return :created
      else
        return :invalid
      end
    end

  end
end
