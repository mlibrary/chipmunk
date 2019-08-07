class Deposit < ApplicationRecord

  # Each deposit is created by a single user
  belongs_to :user
  # A deposit is an attempt to append a revision to a single artifact
  belongs_to :artifact

  validates :user_id, presence: true
  validates :artifact_id, presence: true
  validates :status, presence: true # TODO this is a controlled vocabulary


  def upload_link
    Services.incoming_storage.upload_link(self)
  end

  # fields so far:
  # id
  # artifact_id
  # user_id

end
