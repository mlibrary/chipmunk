require "rails_helper"

RSpec.describe AuditMailer, type: :mailer do
  let(:audit_user) { double(:audit_user, email: Faker::Internet.email) }
  let(:package_user) { double(:package_user, email: Faker::Internet.email) }
  let(:audit) { double(:audit, user: audit_user) }
  let(:package) { double(:package, 
                         user: package_user, 
                         content_type: Faker::Lorem.word, 
                         external_id: SecureRandom.uuid) }
  let(:mailer) { described_class }
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:error) { Faker::Lorem.sentence }

  def send_email
    mailer.failure(audit: audit, package: package, error: error).deliver_now
  end

  describe "#failure" do
    it "sends an email" do
      expect { send_email }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "sends the email to the audit user" do 
      send_email
      expect(email.to).to include(audit_user.email)
    end

    it "sends the email to the package owner" do 
      send_email
      expect(email.to).to include(package_user.email)
    end

    it "sends the email with the subject Audit Failure" do
      send_email
      expect(email.subject).to match(/Audit Failure/)
    end

    it "sends the email with the error detail in the body" do
      send_email
      expect(email.body.encoded).to match(error)
    end

    it "lists the package external id in the subject" do
      send_email
      expect(email.subject).to match(package.external_id)
    end

    it "lists the package content type in the subject" do
      send_email
      expect(email.subject).to match(package.content_type)
    end

    it "sends the email to the configured from address" do
      send_email
      expect(email.from).to contain_exactly(Chipmunk.config.default_from)
    end
  end
end
