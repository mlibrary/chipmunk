# frozen_string_literal: true

Fabricator(:queue_item) do
  package { Fabricate(:package) }
end
