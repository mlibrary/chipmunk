# frozen_string_literal: true

require "rails_helper"

RSpec.describe V1::AuditsController, type: :controller do
  describe "/v1" do
    let!(:audit) { Fabricate(:audit) }

    describe "GET #show" do
      context "as an admin" do
        include_context "as admin user"
        before(:each) { request.headers.merge! auth_header }

        it "assigns an audit presenter" do
          get :show, params: { id: audit.id }
          expect(assigns(:audit).successes).to eq(0)
        end

        it "can expand the audit"
      end

      context "as a non-admin" do
        include_context "as underprivileged user"
        before(:each) { request.headers.merge! auth_header }

        it "returns a 403" do
          get :show, params: { id: audit.id }
          expect(response).to have_http_status(403)
        end
      end

      context "as a user that is not logged in" do
        it "returns a 401" do
          get :show, params: { id: audit.id }
          expect(response).to have_http_status(401)
        end
      end
    end

    describe "GET #index" do
      context "as an admin" do
        include_context "as admin user"
        before(:each) { request.headers.merge! auth_header }

        it "assigns an array of audit presenters" do
          get :index
          expect(assigns(:audits).first.successes).to eq(0)
        end

        it "can expand the audit"
      end

      context "as a non-admin" do
        include_context "as underprivileged user"
        before(:each) { request.headers.merge! auth_header }

        it "returns a 403" do
          get :index
          expect(response).to have_http_status(403)
        end
      end

      context "as a user that is not logged in" do
        it "returns a 401" do
          get :index
          expect(response).to have_http_status(401)
        end
      end
    end
  end

  describe "/v1" do
    describe "POST #create" do
      # create two packages
      context "as an administrator" do
        include_context "as admin user"

        let!(:packages) { Array.new(2) { Fabricate(:package) } }
        let!(:unstored_package) { Fabricate(:package, storage_location: nil) }

        before(:each) do
          # should not appear in audit since it has no storage to audit
          request.headers.merge! auth_header
          allow(FixityCheckJob).to receive(:perform_later)
        end

        it "starts a FixityCheckJob for each stored package" do
          post :create

          packages.each do |package|
            expect(FixityCheckJob).to have_received(:perform_later).with(package, user)
          end
        end

        it "creates an Audit object" do
          post :create

          expect(Audit.count).to eql(1)
        end

        it "creates an Audit object whose owners is the current user" do
          post :create

          expect(Audit.first.user).to eq(user)
        end

        it "creates an Audit object whose count is the number of packages" do
          post :create

          expect(Audit.first.packages).to eql(2)
        end

        it "does not start a FixityCheckJob for unstored packages (requests)" do
          post :create

          expect(FixityCheckJob).not_to have_received(:perform_later).with(unstored_package, user)
        end
      end

      context "as a non-admin" do
        include_context "as underprivileged user"

        before(:each) do
          allow(FixityCheckJob).to receive(:perform_later)
          request.headers.merge! auth_header
          post :create
        end

        it "returns a 403" do
          expect(response).to have_http_status(403)
        end

        it "does not start any jobs" do
          expect(FixityCheckJob).not_to have_received(:perform_later)
        end

        it "does not create an audit object" do
          get :index
          expect(Audit.count).to eql(0)
        end
      end

      context "as a user that is not logged in" do
        before(:each) do
          allow(FixityCheckJob).to receive(:perform_later)
          post :create
        end

        it "returns a 401" do
          expect(response).to have_http_status(401)
        end

        it "does not start any jobs" do
          expect(FixityCheckJob).not_to have_received(:perform_later)
        end

        it "does not create an audit object" do
          get :index
          expect(Audit.count).to eql(0)
        end
      end
    end
  end
end
