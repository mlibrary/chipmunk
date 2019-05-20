# frozen_string_literal: true

class Package < ApplicationRecord

  belongs_to :user
  has_one :queue_item
  has_many :events

  scope :stored, -> { Package.where.not(storage_location: nil) }
  scope :owned, ->(user_id) { Package.where(user_id: user_id) }
  scope :with_type, ->(content_type) { Package.where(content_type: content_type) }
  scope :with_type_and_id, ->(content_type,id) { Package.where(content_type: content_type, id: id) }


  def to_param
    bag_id
  end

  validates :bag_id, presence: true, length: { minimum: 6 }
  validates :user_id, presence: true
  validates :external_id, presence: true

  # Declare the policy class to use for authz
  def self.policy_class
    PackagePolicy
  end

  def src_path
    File.join(Rails.application.config.upload["upload_path"], user.username, bag_id)
  end

  def dest_path
    prefixes = bag_id.match(/^(..)(..)(..).*/)
    raise "bag_id too short" unless prefixes

    File.join(Rails.application.config.upload["storage_path"], *prefixes[1..3], bag_id)
  end

  def upload_link
    File.join(Rails.application.config.upload["rsync_point"], bag_id)
  end

  def stored?
    storage_location != nil
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
    self.content_types
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
      Package.content_types.map { |t| Checkpoint::Resource::AllOfType.new(t) }
    end

    def resource_type
      'Package'
    end

    def resource_id
      Checkpoint::Resource::ALL
    end
  end
end
