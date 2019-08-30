class Revision < ApplicationRecord
  belongs_to :artifact
  belongs_to :deposit
end
