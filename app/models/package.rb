# frozen_string_literal: true

class Package < ApplicationRecord

  belongs_to :user
  has_one :queue_item
  has_many :events

  scope :stored, -> { Package.where.not(storage_volume: nil, storage_location: nil) }
  scope :owned, ->(user_id) { Package.where(user_id: user_id) }
  scope :with_type, ->(content_type) { Package.where(content_type: content_type) }
  scope :with_type_and_id, ->(content_type, id) { Package.where(content_type: content_type, id: id) }

  def to_param
    bag_id
  end

  validates :bag_id, presence: true, length: { minimum: 6 }
  validates :user_id, presence: true
  validates :external_id, presence: true
  validates :format, presence: true

  class Format < String
    class Bag < Format
      def initialize
        super("bag")
      end
    end

    def self.bag
      Bag.new
    end
  end

  # Declare the policy class to use for authz
  def self.policy_class
    PackagePolicy
  end

  # @deprecated need to remove actual paths leaking from the package
  # TODO: Wrap up the concept and config of incoming bags and set up a volume
  #       for that, separate from the preservation storage.
  def src_path
    File.join(Rails.application.config.upload["upload_path"], user.username, bag_id)
  end

  def dest_path
    if format == Format.bag
      prefixes = bag_id.match(/^(..)(..)(..).*/)
      raise "bag_id too short" unless prefixes

      # TODO: Temporary path handling based on the "root" volume and applying
      #       the upload.storage_path within it. This will fall away when there
      #       is a structured way to move packages between volumes.
      # TODO: Find a replacement/wrapper for Pathname; its path1 + path2
      #       behavior is to take path2 if it is absolute. We want the
      #       semantics and consistency of storage paths as absolute _within_
      #       the volume. With Pathname's behavior, we have to be careful that
      #       we don't clobber the storage root. This concern should be wrapped
      #       up somewhere specific so it doesn't trickle through the app.
      root = volumes.find("bags").root_path
      config_base = Rails.application.config.upload["storage_path"].sub(/^\/*/, "")
      pairtree = File.join(prefixes[1..3])

      (root/config_base/pairtree/bag_id).to_s
    else
      raise Chipmunk::UnsupportedFormatError, "Package #{bag_id} has invalid format: #{format}"
    end
  end

  def upload_link
    File.join(Rails.application.config.upload["rsync_point"], bag_id)
  end

  def stored?
    !storage_volume.nil? && !storage_path.nil?
  end

  def storage_path
    attribute(:storage_location)
  end

  def storage_path=(path)
    write_attribute(:storage_location, path)
  end

  # TODO: While Package is still responsible for sharing its absolute path in
  # various places, this adapts the reader to give absolute while the writer
  # is relative. While using the root volume, they are equivalent.
  def storage_location
    if stored?
      volumes.find(storage_volume).expand(storage_path).to_s
    end
  end

  # TODO: This is nasty... but the storage factory checks that the package is stored,
  # so we have to make the storage proxy manually here. Once the ingest and preservation
  # responsibilities are clarified, this will fall out. See PFDR-184.
  def valid_for_ingest?(errors = [])
    if stored?
      errors << "Package #{bag_id} is already stored"
    elsif format != Format.bag
      errors << "Package #{bag_id} has invalid format: #{format}"
    elsif !incoming_storage.include?(self)
      errors << "Bag does not exist at upload location: .../#{user.username}/#{bag_id}"
    end

    return false unless errors.empty?

    Chipmunk::Bag::Validator.new(self, errors, incoming_storage.for(self)).valid?
  end

  def external_validation_cmd
    ext_cmd = Rails.application.config.validation["external"][content_type.to_s]
    return unless ext_cmd

    [ext_cmd, external_id, src_path].join(" ")
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

  def volumes
    @volumes ||= Services.volumes
  end

  def package_storage
    @package_storage ||= Services.storage
  end

  def incoming_storage
    @incoming_storage ||= Services.incoming_storage
  end
end
