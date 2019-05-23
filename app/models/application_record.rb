# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :any_of, ->(*scopes) { scopes.reduce(:or) }

  scope :with_type, ->(type) { type == to_s ? all : none }
  scope :with_type_and_id, ->(type, id) { type == to_s ? where(id: id) : none }
end
