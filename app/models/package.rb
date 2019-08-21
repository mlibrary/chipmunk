# frozen_string_literal: true

class Package < ApplicationRecord

  belongs_to :user
  has_one :queue_item
  has_many :events

  scope :stored, -> { Package.where.not(storage_volume: nil, storage_path: nil) }
  scope :owned, ->(user_id) { Package.where(user_id: user_id) }
  scope :with_type, ->(content_type) { Package.where(content_type: content_type) }
  scope :with_type_and_id, ->(content_type, id) { Package.where(content_type: content_type, id: id) }

  def to_param
    bag_id
  end
  alias_method :identifier, :to_param

  validates :bag_id, presence: true, length: { minimum: 6 }
  validates :user_id, presence: true
  validates :external_id, presence: true
  validates :format, presence: true

  # Declare the policy class to use for authz
  def self.policy_class
    PackagePolicy
  end

  def username
    user.username
  end

  def upload_link
    Services.incoming_storage.upload_link(self)
  end

  def stored?
    !storage_volume.nil? && !storage_path.nil?
  end

  # V1 API exposes the absolute path to storage.
  def storage_location
    package_storage.for(self).path if stored?
  rescue Chipmunk::PackageNotFoundError
    storage_path
  end

  def storage_location=
    raise "storage_location is not writable; use storage_volume and storage_path"
  end

  # TODO: This is nasty... but the storage factory checks that the package is stored,
  # so we have to make the storage proxy manually here. Once the ingest and preservation
  # responsibilities are clarified, this will fall out. See PFDR-184.
  def valid_for_ingest?(errors = [])
    if stored?
      errors << "Package #{bag_id} is already stored"
    elsif format != Chipmunk::Bag.format
      errors << "Package #{bag_id} has invalid format: #{format}"
    elsif !incoming_storage.include?(self)
      errors << "Bag #{bag_id} does not exist in incoming storage."
    end

    return false unless errors.empty?

    Chipmunk::Bag::Validator.new(self, errors, incoming_storage.for(self)).valid?
  end

  def external_validation_cmd
    ext_cmd = Rails.application.config.validation["external"][content_type.to_s]
    return unless ext_cmd

    path = incoming_storage.for(self).path
    [ext_cmd, external_id, path].join(" ")
  end

  def bagger_profile
    Rails.application.config.validation["bagger_profile"][content_type.to_s]
  end

  def resource_type
    content_type
  end

  def self.resource_types
    content_types
  end

  def self.content_types
    Rails.application.config.validation["bagger_profile"].keys +
      Rails.application.config.validation["external"].keys
  end

  def self.of_any_type
    AnyPackage.new
  end

  class AnyPackage
    def to_resources
      Package.content_types.map {|t| Checkpoint::Resource::AllOfType.new(t) }
    end

    def resource_type
      "Package"
    end

    def resource_id
      Checkpoint::Resource::ALL
    end
  end

  private

  def package_storage
    @package_storage ||= Services.storage
  end

  def incoming_storage
    @incoming_storage ||= Services.incoming_storage
  end
end
