# frozen_string_literal: true

# @param collection_policy [Policy] The controller's collection policy class name; 
#        used to make verifying instance_doubles
RSpec.shared_examples "an index endpoint" do |collection_policy|
  describe "GET #index" do
    let(:resource) { double(:resource) }
    let(:policy)   { collection_policy_double(collection_policy, [resource], index?: true) }

    before(:each) do
      controller.fake_user(Fabricate(:user))
      controller.collection_policy = policy
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
