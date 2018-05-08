# frozen_string_literal: true

require "rails_helper"

describe "/v1/audits/show.json.jbuilder" do
  let(:user) { double(:user, admin?: true) }

  before(:each) do
    assign(:audit, audit)
    assign(:current_user, user)
  end

  context "with expand=false" do
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
        created_at: Time.now,
        expand: false,
        updated_at: Time.now)
    end

    let(:expected) do
      {
        id:        audit.id,
        successes: success_count,
        failures:  failure_count,
        packages:  package_count,
        user:      audit.user.username,
        date:      audit.created_at.to_formatted_s(:default)
      }
    end

    it "renders correct compact json" do
      render
      expect(JSON.parse(rendered, symbolize_names: true)).to eql(expected)
    end
  end

  context "with expand=true" do
    let(:package_count) { 1 }

    let(:event) do
      double(:event,
        id: 1,
        event_type: Faker::Lorem.word,
        user: double(:user, username: Faker::Internet.user_name),
        outcome: Faker::Lorem.word,
        detail: Faker::Lorem.sentence,
        created_at: Time.now,
        updated_at: Time.now)
    end

    let(:expected_event) do
      {              id:       event.id,
                     type:     event.event_type,
                     executor: event.user.username,
                     outcome:  event.outcome,
                     detail:   event.detail,
                     date:     event.created_at.to_formatted_s(:default) }
    end

    let(:audit) do
      double(:audit,
        id: 1,
        successes: [event],
        failures: [],
        packages: Array.new(package_count) {|n| double(:"package#{n}") },
        user: double(:user, username: Faker::Internet.user_name),
        created_at: Time.now,
        expand: true,
        updated_at: Time.now)
    end

    let(:expected) do
      {
        id:        audit.id,
        successes: [expected_event],
        failures:  [],
        packages:  package_count,
        user:      audit.user.username,
        date:      audit.created_at.to_formatted_s(:default)
      }
    end

    it "renders correct expanded json" do
      render
      expect(JSON.parse(rendered, symbolize_names: true)).to eql(expected)
    end
  end
end
