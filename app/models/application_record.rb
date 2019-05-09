# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :any_of, ->(*scopes) { scopes.reduce(:or) }

  # by default there's a 1-1 map between checkpoint resource types and AR model
  # resource types, but specific models can override that.
  scope :with_type, ->(_) { self.all }
  scope :with_type_and_id, ->(_) { self.where(id: id) }
end
