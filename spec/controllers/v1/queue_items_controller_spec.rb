# frozen_string_literal: true

require "rails_helper"

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
      let(:result_status) { status }
      let(:builder) { double(:builder) }
      let(:status) { nil }
      let(:bag_move_job) { double(:bag_move_job, perform_later: nil) }

      before(:each) do
        controller.bag_move_job = bag_move_job
      end

      shared_examples "a duplicate" do
        before(:each) do
          resource_policy "QueueItemPolicy", show?: true
        end

        it "responds with 303" do
          post :create, params: { bag_id: package.bag_id }
          expect(response).to have_http_status(303)
        end
        it "populates the location header" do
          post :create, params: { bag_id: package.bag_id }
          expect(response.location).to eql(v1_queue_item_path(queue_item.id))
        end
        it "renders nothing" do
          post :create, params: { bag_id: package.bag_id }
          expect(response).to render_template(nil)
        end
        it "does not create a queue item" do
          expect { post :create, params: { bag_id: package.bag_id } }.not_to change(QueueItem, :count)
        end
        it "does not enqueue a BagMoveJob" do
          expect(bag_move_job).not_to receive(:perform_later)
          post :create, params: { bag_id: package.bag_id }
        end
      end

      shared_examples "creates a new queue item" do
        before(:each) do
          resource_policy "QueueItemPolicy", save?: true
          collection_policy "QueueItemsPolicy", new?: true
        end

        it "responds with 201" do
          post :create, params: { bag_id: package.bag_id }
          expect(response).to have_http_status(201)
        end
        it "populates the location header" do
          post :create, params: { bag_id: package.bag_id }
          expect(response.location).to eql(v1_queue_item_path(assigns(:queue_item).id))
        end
        it "renders nothing" do
          post :create, params: { bag_id: package.bag_id }
          expect(response).to render_template(nil)
        end
        it "creates a queue item" do
          expect { post :create, params: { bag_id: package.bag_id } }.to change(QueueItem, :count).by(1)
        end
        it "the queue item is for the expected descriptor" do
          post :create, params: { bag_id: package.bag_id }
          expect(assigns(:queue_item).package).to eql(package)
        end
        it "the queue_item is pending" do
          post :create, params: { bag_id: package.bag_id }
          expect(assigns(:queue_item).pending?).to be true
        end
        it "enqueues a BagMoveJob" do
          expect(bag_move_job).to receive(:perform_later)
          post :create, params: { bag_id: package.bag_id }
        end
      end

      context "when a pending queue item already exists" do
        let!(:queue_item) { Fabricate(:queue_item, package: package, status: :pending) }

        it_behaves_like "a duplicate"
      end

      context "when a done queue item already exists" do
        let!(:queue_item) { Fabricate(:queue_item, package: package, status: :done) }

        it_behaves_like "a duplicate"
      end

      context "when a failed queue item already exists" do
        let!(:queue_item) { Fabricate(:queue_item, package: package, status: :failed) }

        it_behaves_like "creates a new queue item"
      end

      context "when a queue item does not exist" do
        it_behaves_like "creates a new queue item"
      end

      context "when the policy denies the user access" do
        before(:each) { resource_policy "QueueItemPolicy", save?: false }

        it "responds with 403 Forbidden" do
          post :create, params: { bag_id: package.bag_id }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
