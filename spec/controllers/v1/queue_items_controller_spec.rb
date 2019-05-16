# frozen_string_literal: true

require "rails_helper"
require "support/helpers/policy_double"
require "support/contexts/with_someone_logged_in"

RSpec.describe V1::QueueItemsController, type: :controller do
  include Checkpoint::Spec::Controller

  describe "/v1" do
    it "uses QueueItemsPolicy as its collection policy" do
      policy = controller.send(:collection_policy)
      expect(policy).to eq QueueItemsPolicy
    end

    it "uses QueueItemPolicy as its resource policy" do
      policy = controller.send(:resource_policy)
      expect(policy).to eq QueueItemPolicy
    end

    describe "GET #index" do
      include_context "with someone logged in"
      let!(:package) { Fabricate(:package, user: user) }
      let!(:intersection) { Fabricate.times(2, :queue_item, package: package) }
      let!(:disjoint) { Fabricate.times(2, :queue_item, package: Fabricate(:package, user: user)) }

      before(:each) { collection_policy "QueueItemsPolicy", QueueItem.all, index?: true }

      it "returns 200" do
        get :index
        expect(response).to have_http_status(200)
      end

      it "renders only the records from the policy" do
        get :index
        expect(assigns(controller.controller_name))
          .to contain_exactly(*(disjoint + intersection))
      end

      it "renders the correct template" do
        get :index
        expect(response).to render_template(:index)
      end

      it "returns only matching packages" do
        get :index, params: { package: package.id }
        expect(assigns(:queue_items)).to contain_exactly(*intersection)
      end
    end

    describe "GET #show" do
      context "when the policy allows the user access" do
        include_context "with someone logged in"
        let(:queue_item) { Fabricate(:queue_item) }

        before(:each) { resource_policy "QueueItemPolicy", show?: true }

        it "returns 200" do
          get :show, params: { id: queue_item.id }
          expect(response).to have_http_status(200)
        end

        it "renders the queue_item" do
          get :show, params: { id: queue_item.id }
          expect(assigns(:queue_item)).to eq queue_item
        end

        it "renders the show template" do
          get :show, params: { id: queue_item.id }
          expect(response).to render_template(:show)
        end
      end

      context "when the record does not exist" do
        include_context "with someone logged in"

        it "raises an ActiveRecord::RecordNotFound" do
          expect do
            get :show, params: { id: "(missing)" }
          end.to raise_exception ActiveRecord::RecordNotFound
        end
      end
    end

    describe "POST #create" do
      include_context "with someone logged in"

      let!(:package) { Fabricate(:package, user: user) }
      let(:result_queue_item) { Fabricate(:queue_item, package_id: package.bag_id) }
      let(:result_status) { status }
      let(:builder) { double(:builder) }
      let(:status) { nil }

      before(:each) do
        allow(QueueItemBuilder).to receive(:new).and_return(builder)
        allow(builder).to receive(:create).and_return([result_status, result_queue_item])
        resource_policy "QueueItemPolicy", create?: true
      end

      context "QueueItemBuilder returns status==:duplicate" do
        let(:status) { :duplicate }

        it "responds with 303" do
          post :create, params: { bag_id: package.bag_id }
          expect(response).to have_http_status(303)
        end
        it "populates the location header" do
          post :create, params: { bag_id: package.bag_id }
          expect(response.location).to eql(v1_queue_item_path(result_queue_item.id))
        end
        it "renders nothing" do
          post :create, params: { bag_id: package.bag_id }
          expect(response).to render_template(nil)
        end
      end

      context "QueueItemBuilder returns status==:created" do
        let(:status) { :created }

        it "responds with 201" do
          post :create, params: { bag_id: package.bag_id }
          expect(response).to have_http_status(201)
        end
        it "populates the location header" do
          post :create, params: { bag_id: package.bag_id }
          expect(response.location).to eql(v1_queue_item_path(result_queue_item.id))
        end
        it "renders nothing" do
          post :create, params: { bag_id: package.bag_id }
          expect(response).to render_template(nil)
        end
      end

      context "QueueItemBuilder returns status==:invalid" do
        let(:status) { :invalid }

        it "responds with 422" do
          post :create, params: { bag_id: package.bag_id }
          expect(response).to have_http_status(422)
        end
        it "renders nothing" do
          post :create, params: { bag_id: package.bag_id }
          expect(response).to render_template(nil)
        end
      end

      context "when the policy denies the user access" do
        before(:each) { resource_policy "QueueItemPolicy", create?: false }

        it "responds with 403 Forbidden" do
          post :create, params: { bag_id: package.bag_id }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
