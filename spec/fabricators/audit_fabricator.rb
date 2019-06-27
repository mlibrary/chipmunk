# frozen_string_literal: true

Fabricator(:audit) do
  user { Fabricate(:user) }
  packages { Package.stored.count }
end
