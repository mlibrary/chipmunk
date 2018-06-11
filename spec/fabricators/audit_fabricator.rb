# frozen_string_literal: true

Fabricator(:audit) do
  user { Fabricate(:user) }
  packages { 0 }
end
