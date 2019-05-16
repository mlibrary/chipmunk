# frozen_string_literal: true

require "rails_helper"
require "support/helpers/policy_double"
require "support/contexts/with_someone_logged_in"
require "support/examples/an_index_endpoint"

RSpec.describe V1::EventsController, type: :controller do
  include Checkpoint::Spec::Controller
  describe "/v1" do
    it "uses EventsPolicy as its collection policy" do
      policy = controller.send(:collection_policy)
      expect(policy).to eq EventsPolicy
    end

    it_behaves_like "an index endpoint", "EventsPolicy"

    describe "GET #index" do
      context "with events for two packages" do
        include_context "with someone logged in"

        let!(:package) { Fabricate(:package) }
        let!(:events) { [Fabricate(:event, package: package), Fabricate(:event, package: package)] }

        before(:each) do
          # create an extra event that shouldn't be in the output
          Fabricate(:event)
          collection_policy "EventsPolicy", events, index?: true
        end

        it "can show only events for an object identified by bag_id" do
          get :index, params: { bag_id: package.bag_id }
          expect(assigns(:events)).to eq(events)
        end

        it "can show only events for an object identified by external_id" do
          get :index, params: { bag_id: package.external_id }
          expect(assigns(:events)).to eq(events)
        end
      end
    end
  end
end
