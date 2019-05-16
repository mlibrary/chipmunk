# frozen_string_literal: true

class Package < ApplicationRecord
  class VolumeType < ActiveRecord::Type::String
    def cast(value)
      value ||= ""
      Chipmunk::Volume.new(value)
    end
    def serialize(value)
      value.to_s
    end
  end

  belongs_to :user
  has_one :queue_item
  has_many :events

  scope :stored, -> { Package.where.not(storage_location: nil) }
  scope :owned, ->(user_id) { Package.where(user_id: user_id) }

  def to_param
    bag_id
  end

  validates :bag_id, presence: true, length: { minimum: 6 }
  validates :user, presence: true
  validates :external_id, presence: true
  validates :storage_volume, presence: true
  validates :content_type, presence: true

  attribute :storage_volume, VolumeType.new

  # Declare the policy class to use for authz
  def self.policy_class
    PackagePolicy
  end

  def src_path
    File.join(Rails.application.config.upload["upload_path"], user.username, bag_id)
  end

  # TODO: should be removable
  def dest_path
    prefixes = bag_id.match(/^(..)(..)(..).*/)
    raise "bag_id too short" unless prefixes

    File.join(Rails.application.config.upload["storage_path"], *prefixes[1..3], bag_id)
  end

  def upload_link
    File.join(Rails.application.config.upload["rsync_point"], bag_id)
  end

  # TODO Remove this method entirely; should be the responsibility of something else
  def stored?
    storage_location != nil
    storage_volume == Chipmunk::Volume.new("bag:1")
    # Services.packages.find(volume: storage_volume, id: bag_id)
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

end
