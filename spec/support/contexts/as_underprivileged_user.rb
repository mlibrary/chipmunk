# frozen_string_literal: true

RSpec.shared_context "as underprivileged user" do
  let(:user) { Fabricate(:user, admin: false) }
  before(:each) { controller.fake_user(user) }
end
