# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :any_of, ->(*scopes) { scopes.reduce(:or) }

  scope :with_type, ->(type) { type == self.to_s ? self.all : self.none }
  scope :with_type_and_id, ->(type,id) { type == self.to_s ? self.where(id: id) : self.none }
end
