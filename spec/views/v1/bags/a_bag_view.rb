RSpec.shared_examples_for "a bag view"  do |assignee,wrapper|
  let(:bag) do
    double(:bag,
      bag_id: SecureRandom.uuid,
      user: double(:user, username: Faker::Internet.user_name),
      external_id: SecureRandom.uuid,
      storage_location: nil,
      external_service: "mirlyn",
      upload_link: "#{Faker::Internet.email}:/#{Faker::Lorem.word}/path",
      content_type: "fake",
      created_at: Time.at(0),
      updated_at: Time.now
    )
  end
  let(:expected) do
    {
      bag_id: bag.bag_id,
      user: bag.user.username,
      external_id: bag.external_id,
      content_type: bag.content_type,
      created_at: bag.created_at.to_formatted_s(:default),
      updated_at: bag.updated_at.to_formatted_s(:default)
    }
  end
  let(:admin_user) { double(:admin_user, admin?: true) }
  let(:unprivileged_user) { double(:unpriv_user, admin?: false) }


  before(:each) do
    assign(assignee, wrapper.call(bag))
  end

  context "with a completed bag (has storage location)" do
    before(:each) do
      allow(bag).to receive(:storage_location)
        .and_return "#{Faker::Lorem.word}/path"
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
          .to eql wrapper.call(expected.merge({storage_location: bag.storage_location}))
      end
    end
  end

  context "with an incomplete bag (no storage location)" do
    it "renders correct json w/ upload_link" do
      render
      expect(JSON.parse(rendered, symbolize_names: true))
        .to eql wrapper.call(expected.merge({upload_link: bag.upload_link}))
    end
  end
end
