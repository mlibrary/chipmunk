class Artifact < ApplicationRecord

  class AnyArtifact
    def to_resources
      Artifact.content_types.map {|t| Checkpoint::Resource::AllOfType.new(t) }
    end

    def resource_type
      "Artifact"
    end

    def resource_id
      Checkpoint::Resource::ALL
    end
  end

  def self.resource_types
    content_types
  end

  def self.content_types
    Rails.application.config.validation["bagger_profile"].keys +
      Rails.application.config.validation["external"].keys
  end

  def self.of_any_type
    AnyArtifact.new
  end


  # Each artifact belongs to a single user
  belongs_to :user
  # Deposits are collections of zero or more revisions
  has_many :revisions

  def to_param
    artifact_id
  end

  validates :artifact_id, presence: true
  validates :user_id, presence: true
  validates :content_type, presence: true # TODO this is a controlled vocabulary

end
