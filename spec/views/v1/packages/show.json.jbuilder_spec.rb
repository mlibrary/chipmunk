# frozen_string_literal: true

require "rails_helper"
require_relative "./a_package_view"

describe "/v1/packages/show.json.jbuilder" do
  it_behaves_like "a package view", :package, ->(package) { package }, true
end
