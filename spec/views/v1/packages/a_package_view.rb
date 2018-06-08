# frozen_string_literal: true

# wrapper: a lambda that transforms the bag (assigns for the view) and the
# expected JSON output. Examples: for show, this should be the identity
# function; for index, it should wrap the passed object in an array.
RSpec.shared_examples_for "a package view" do |assignee, wrapper, expand|
  let(:package) do
    double(:package,
      bag_id: SecureRandom.uuid,
      user: double(:user, username: Faker::Internet.user_name),
      external_id: SecureRandom.uuid,
      storage_location: "#{Faker::Lorem.word}/path",
      external_service: "mirlyn",
      upload_link: "#{Faker::Internet.email}:/#{Faker::Lorem.word}/path",
      content_type: "fake",
      created_at: Time.at(0),
      updated_at: Time.now,
      stored?: true)
  end
  let(:package_file) { Faker::Lorem.word }
  let(:expected) do
    {
      bag_id:       package.bag_id,
      user:         package.user.username,
      external_id:  package.external_id,
      content_type: package.content_type,
      upload_link:  package.upload_link,
      created_at:   package.created_at.to_formatted_s(:default),
      updated_at:   package.updated_at.to_formatted_s(:default),
      files:        [ package_file ],
      stored:       package.stored?
    }
  end
  let(:bag) do
    double(:bag,
           data_dir: File.join(package.storage_location,"data"),
           bag_files: [File.join(package.storage_location,"data",package_file)])
  end
  let(:admin_user) { double(:admin_user, admin?: true) }
  let(:unprivileged_user) { double(:unpriv_user, admin?: false) }

  before(:each) do
    if !expand
      expected.delete(:files)
    end

    assign(assignee, wrapper.call(package))
    @storage = Services.storage
    Services.register(:storage) { double(:storage, new: bag) }
  end

  after(:each) do
    Services.register(:storage) { @storage }
  end

  context "when the user is underprivileged" do
    before(:each) { assign(:current_user, unprivileged_user) }
    it "renders correct json w/o storage_location" do
      render
      expect(JSON.parse(rendered, symbolize_names: true)).to eql(wrapper.call(expected))
    end
  end

  context "when the user is an admin" do
    before(:each) { assign(:current_user, admin_user) }
    it "renders correct json w/ storage_location" do
      render
      expect(JSON.parse(rendered, symbolize_names: true))
        .to eql wrapper.call(expected.merge(storage_location: package.storage_location))
    end
  end
end
