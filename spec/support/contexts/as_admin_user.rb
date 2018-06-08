# frozen_string_literal: true

RSpec.shared_context "as admin user" do
  let(:user) { Fabricate(:user, admin: true) }
  before(:each) { controller.fake_user(user) }
end
