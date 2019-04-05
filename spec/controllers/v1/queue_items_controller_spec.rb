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

    it_behaves_like "an index endpoint", 'QueueItemsPolicy'

    describe "GET #show" do
      include_context "as underprivileged user"

      before { resource_policy 'QueueItemPolicy', show?: true }

      context "when the resource belongs to the user" do
        let(:uuid)       { SecureRandom.uuid }
        let(:user)       { Fabricate(:user) }
        let(:package)    { Fabricate(:package, user: user) }
        let(:queue_item) { Fabricate(:queue_item, package: package) }

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
        it "raises an ActiveRecord::RecordNotFound" do
          expect do
            get :show, params: { id: '(missing)' }
          end.to raise_exception ActiveRecord::RecordNotFound
        end
      end
    end

    describe "POST #create" do
      include_context "as underprivileged user"

      let!(:package) { Fabricate(:package, user: user) }
      let(:result_queue_item) { Fabricate(:queue_item, package_id: package.bag_id) }
      let(:result_status) { status }
      let(:builder) { double(:builder) }
      let(:status) { nil }

      before(:each) do
        allow(QueueItemBuilder).to receive(:new).and_return(builder)
        allow(builder).to receive(:create).and_return([result_status, result_queue_item])
        resource_policy 'QueueItemPolicy', create?: true
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

      it "rejects unauthorized users" do
        resource_policy 'QueueItemPolicy', create?: false
        post :create, params: { bag_id: package.bag_id }
        expect(response).to have_http_status(403)
      end
    end
  end
end
