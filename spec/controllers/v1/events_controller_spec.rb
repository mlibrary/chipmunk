# frozen_string_literal: true

require "rails_helper"

RSpec.describe V1::EventsController, type: :controller do
  describe "/v1" do
    describe "GET #index" do
      it_behaves_like "an index endpoint" do
        let(:key) { :event_id }
        # for underprivileged users, should only render events where the bag
        # belongs to the user
        let(:factory) do
          proc do |user| 
            if user
              Fabricate(:event, bag: Fabricate(:bag, user: user))
            else 
              Fabricate(:event)
            end
          end
        end
        let(:assignee) { :events }
      end

      context "with events for two bags" do
        include_context "as admin user"

        let!(:bag) { Fabricate(:bag) }
        let!(:events) { [Fabricate(:event, bag: bag), Fabricate(:event, bag: bag)] }
        before(:each) do
          # create an extra event that shouldn't be in the output
          Fabricate(:event)
          request.headers.merge! auth_header
        end

        it "can show only events for an object identified by bag_id" do
          get :index, params: { bag_id: bag.bag_id }
          expect(assigns(:events)).to eq(events)
        end

        it "can show only events for an object identified by external_id" do
          get :index, params: { bag_id: bag.external_id }
          expect(assigns(:events)).to eq(events)
        end

      end
    end
  end
end
