require 'rails_helper'

RSpec.describe RequestBuilder do

  let(:config_rsync_point) { Rails.application.config.upload['rsync_point'] }
  let(:config_upload_path) { Rails.application.config.upload['upload_path'] }
  let(:user) { Fabricate(:user) }

  describe "#create" do
    let(:params) do
      { content_type: 'audio', user: user, bag_id: SecureRandom.uuid, external_id: "blah" }
    end

    it "returns a Request with the configured upload link" do
      expected_link = File.join(config_rsync_point, user.username, params[:bag_id])
      expect(described_class.new(params).create.upload_link).to eql expected_link
    end

    it "creates a DigitalRequest when content_type 'digital'" do
      builder = described_class.new(params.merge(content_type: 'digital'))
      expect(builder.create).to be_an_instance_of(DigitalRequest)
    end

    it "creates an AudioRequest when content_type 'audio'" do
      builder = described_class.new(params.merge(content_type: 'audio'))
      expect(builder.create).to be_an_instance_of(AudioRequest)
    end

    context "when building two different requests" do
      let (:params1) { {content_type: 'audio', bag_id: '1', 
                        external_id: 'foo', user: user} }
      let (:request1) { described_class.new(params1).create }

      let (:params2) { {content_type: 'audio', bag_id: '2', 
                        external_id: 'bar', user: user } }
      let (:request2) { described_class.new(params2).create }

      it "returns a different upload link" do
        expect(request1.upload_link).not_to eq(request2.upload_link)
      end
      
    end
  end
end

