require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  # doesn't matter what, just needs to exist
  AN_EXISTING_TEMPLATE = 'v1/audits/show'

  controller do
    def something
      render AN_EXISTING_TEMPLATE
      @something = "success"
    end
  end

  let(:auth_header) { {} }
  let(:remote_user_header) { {} }

  before(:each) do
    routes.draw { get "something" => "anonymous#something" }
    request.headers.merge! auth_header
    request.headers.merge! remote_user_header
    get :something
  end

  subject { response }

  shared_examples_for "an allowed request" do
    it { is_expected.to have_http_status(200) } 
    it { is_expected.to render_template(AN_EXISTING_TEMPLATE) } 

    it "executes the controller action" do
      expect(assigns(:something)).to eq('success')
    end
  end

  shared_examples_for "a disallowed request" do
    it { is_expected.to render_template(nil) } 

    it "does not execute the controller action" do
      expect(assigns(:something)).to be(nil)
    end
  end

  shared_examples_for "respects Authorization header" do
    context "with valid Authorization header" do
      include_context "as admin user"

      it "sets current_user to the user corresponding to the token" do
        expect(controller.current_user).to eq(user)
      end

      it_behaves_like "an allowed request"
    end

    context "with invalid Authorization" do
      include_context "with bad auth token"
      it { is_expected.to have_http_status(401) } 
      it_behaves_like "a disallowed request"
    end
  end

  context "without X-Remote-User" do
    context "without Authorization" do
      it { is_expected.to redirect_to("/login") } 

      it_behaves_like "a disallowed request"
    end

    it_behaves_like "respects Authorization header"
  end

  context "with X-Remote-User" do
    let(:remote_user_header) { { 'X-Remote-User' => 'someuser' } }

    context "without Authorization" do
      # it "sets current_user to a non-persisted user"
      it_behaves_like "an allowed request"
    end

    it_behaves_like "respects Authorization header"
  end
  

end
