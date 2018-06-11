# frozen_string_literal: true

require "rails_helper"

RSpec.describe V1::QueueItemsController, type: :controller do
  describe "/v1" do
    build_proc = proc do |user|
      uuid = SecureRandom.uuid
      if user
        Fabricate(:queue_item, package: Fabricate(:package, bag_id: uuid, user: user))
      else
        Fabricate(:queue_item, package: Fabricate(:package, bag_id: uuid))
      end
    end

    describe "GET #index" do
      it_behaves_like "an index endpoint" do
        let(:key) { :id }
        let(:factory) { build_proc }
        let(:assignee) { :queue_items }
        let(:policy) { QueueItemsPolicy }
      end
    end

    describe "GET #show" do
      it_behaves_like "a show endpoint" do
        let(:key) { :id }
        let(:factory) { build_proc }
        let(:assignee) { :queue_item }
        let(:policy) { QueueItemPolicy }
      end
    end

    describe "POST #create" do
      let(:result_queue_item) { Fabricate(:queue_item, package_id: package.bag_id) }
      let(:result_status) { status }
      let(:builder) { double(:builder) }
      let(:status) { nil }

      before(:each) do
        allow(QueueItemBuilder).to receive(:new).and_return(builder)
        allow(builder).to receive(:create).and_return([result_status, result_queue_item])
      end

      include_context "as underprivileged user"
      let!(:package) { Fabricate(:package, user: user) }

      it "checks the policy with the package" do
        policy = double(:policy)
        allow(QueueItemsPolicy).to receive(:new).with(user).and_return(policy)
        expect(policy).to receive(:create?).with(package)

        post :create, params: { bag_id: package.bag_id }
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
    end
  end
end
