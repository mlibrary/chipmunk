# frozen_string_literal: true

require "rails_helper"

describe "/v1/events/index.json.jbuilder" do
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
  let(:expected) do
    [{
      id: event.id,
      type: event.event_type,
      executor: event.user.username,
      outcome: event.outcome,
      detail: event.detail,
      date:   event.created_at.to_formatted_s(:default),
    }]
  end

  let(:user) { double(:user, admin?: false) }

  before(:each) do
    assign(:events, [event])
    assign(:current_user, user) 
  end

  it "renders correct json" do
    render
    expect(JSON.parse(rendered, symbolize_names: true)).to eql(expected)
  end

end
