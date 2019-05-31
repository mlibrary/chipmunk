# frozen_string_literal: true

require "rails_helper"

describe "/v1/packages/show.json.jbuilder" do
  include_context "with test volume"

  let(:package) { Fabricate.create(:stored_package) }
  let(:bag) { double(:bag, relative_data_files: files) }
  let(:files) { 3.times { Faker::Lorem.word } }

  before(:each) do
    assign(:current_user, user)
    assign(:package, package)
    assign(:bag, bag)
    render
  end

  context "with an underprivileged user" do
    let(:user) { double(:user, admin?: false) }

    it "renders correct json w/o storage details" do
      expect(JSON.parse(rendered, symbolize_names: true))
        .to eql(
          bag_id:       package.bag_id,
          user:         package.user.username,
          content_type: package.content_type,
          external_id:  package.external_id,
          upload_link:  package.upload_link,
          stored:       package.stored?,
          files:        files,
          created_at:   package.created_at.to_formatted_s(:default),
          updated_at:   package.updated_at.to_formatted_s(:default)
        )
    end
  end

  context "with an admin user" do
    let(:user) { double(:admin_user, admin?: true) }

    it "renders correct json w/ storage details" do
      expect(JSON.parse(rendered, symbolize_names: true))
        .to eql(
          bag_id:       package.bag_id,
          user:         package.user.username,
          content_type: package.content_type,
          external_id:  package.external_id,
          upload_link:  package.upload_link,
          storage_location: package.storage_location,
          stored:       package.stored?,
          files:        files,
          created_at:   package.created_at.to_formatted_s(:default),
          updated_at:   package.updated_at.to_formatted_s(:default)
        )
    end
  end
end
