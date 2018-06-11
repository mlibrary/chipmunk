# frozen_string_literal: true

# @param factory [Proc] Proc that optionally takes a user, returns a saved record.
RSpec.shared_examples "an index endpoint" do
  let(:template) do
    described_class.to_s.gsub("Controller", "").underscore + "/index"
  end

  let!(:other) { factory.call }
  let!(:mine) { factory.call(user) }

  context "as underprivileged user" do
    include_context "as underprivileged user"

    it "returns 200" do
      get :index
      expect(response).to have_http_status(200)
    end

    it "renders only the user's records" do
      get :index
      expect(assigns(assignee)).to contain_exactly(mine)
    end

    it "renders the correct template" do
      get :index
      expect(response).to render_template(template)
    end

    it "checks the policy" do
      expect_collection_policy_check(policy: policy, user: user, action: :index?)
      get :index
    end
  end

  context "as admin" do
    include_context "as admin user"

    it "renders all records" do
      get :index
      expect(assigns(assignee)).to contain_exactly(mine, other)
    end

    it "checks the policy" do
      expect_collection_policy_check(policy: policy, user: user, action: :index?)
      get :index
    end
  end
end
