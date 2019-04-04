# frozen_string_literal: true

require 'rails_helper'
require 'ostruct'

# @param resource_policy [String] The name of the resource_policy
# @param factory_name [Symbol] The name of the factory/prototype to create as the resource
# @param params [Proc] A proc that takes the resource and returns a parmeter hash for the get requests
RSpec.shared_examples "a show endpoint" do |resource_policy, factory_name, params|
  include Rails.application.routes.url_helpers

  context "when the resource belongs to the user" do
    let(:user)     { Fabricate(:user) }
    let(:resource) { Fabricate(factory_name, user: user) }
    
    before do
      controller.fake_user user
      get :show, params: params.call(resource)
    end

    it "returns 200" do
      expect(response).to have_http_status(200)
    end

    it "renders the record" do
      expect(assigns(controller.controller_name.singularize)).to eq resource
    end

    it "renders the show template" do
      expect(response).to render_template(:show)
    end
  end

  context "the record does not exist" do
    let(:user)   { Fabricate(:user) }
    let(:record) do
      # This is a funky construct to return a value for anything sent to it.
      # This enables the params lambda to treat existing and nonexistent records the same.
      OpenStruct.new.tap do |record|
        def record.method_missing(m, *args, &block)
          '(missing-value)'
        end
      end
    end

    before do
      controller.fake_user user
    end

    it "raises an ActiveRecord::RecordNotFound" do
      expect do
        get :show, params: params.call(record)
      end.to raise_exception ActiveRecord::RecordNotFound
    end
  end
end
