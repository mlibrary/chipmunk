# frozen_string_literal: true

# @param collection_policy [Policy] The controller's collection policy class name;
#        used to make verifying instance_doubles
RSpec.shared_examples "an index endpoint" do |coll_policy|
  include Checkpoint::Spec::Controller

  describe "GET #index" do
    let(:resource) { double(:resource) }

    before(:each) do
      controller.fake_user(Fabricate(:user))
      collection_policy coll_policy, [resource], index?: true
    end

    it "returns 200" do
      get :index
      expect(response).to have_http_status(200)
    end

    it "renders only the records from the policy" do
      get :index
      expect(assigns(controller.controller_name)).to contain_exactly(resource)
    end

    it "renders the correct template" do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
