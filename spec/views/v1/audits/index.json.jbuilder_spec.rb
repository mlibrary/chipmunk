# frozen_string_literal: true

require "rails_helper"

describe "/v1/audits/index.json.jbuilder" do
  let(:success_count) { 1 }
  let(:failure_count) { 2 }
  let(:package_count) { 3 }

  let(:audit) do
    double(:audit,
      id: 1,
      successes: Array.new(success_count) {|n| double(:"success#{n}") },
      failures: Array.new(failure_count) {|n| double(:"failure#{n}") },
      packages: Array.new(package_count) {|n| double(:"package#{n}") },
      user: double(:user, username: Faker::Internet.user_name),
      expand: false,
      created_at: Time.now,
      updated_at: Time.now)
  end
  let(:expected) do
    [{
      id:        audit.id,
      successes: success_count,
      failures:  failure_count,
      packages:  package_count,
      user:      audit.user.username,
      date:      audit.created_at.to_formatted_s(:default)
    }]
  end

  let(:user) { double(:user, admin?: true) }

  before(:each) do
    assign(:audits, [audit])
    assign(:current_user, user)
  end

  it "renders correct json" do
    render
    expect(JSON.parse(rendered, symbolize_names: true)).to eql(expected)
  end
end
