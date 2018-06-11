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
    before(:each) { get :index, params: {} }

    it "returns 200" do
      expect(response).to have_http_status(200)
    end
    it "renders only the user's records" do
      expect(assigns(assignee)).to contain_exactly(mine)
    end
    it "renders the correct template" do
      expect(response).to render_template(template)
    end
  end

  context "as admin" do
    include_context "as admin user"
    before(:each) { get :index, params: {} }

    it "renders all records" do
      expect(assigns(assignee)).to contain_exactly(mine, other)
    end
  end
end
