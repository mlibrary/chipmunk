require "package_validation"
require "chipmunk/status"

RSpec.describe PackageValidation do
  let(:validation) { described_class.new(validator) }

  describe "#call" do
    context "when the package is valid" do
      let(:validator) { double(:validator, valid?: true, errors: []) }
      it "returns success" do
        expect(validation.call).to eql Chipmunk::Status.success
      end
    end

    context "when the package is invalid" do
      let(:errors) { ['my error'] }
      let(:validator) { double(:validator, valid?: false, errors: errors) }

      it "returns failure w/ errors" do
        expect(validation.call).to eql Chipmunk::Status.failure(errors)
      end
    end

    context "when the validation raises an exception" do
      class InjectedError < StandardError; end
      let(:validator) { double(:validator) }
      before(:each) do
        allow(validator).to receive(:valid?).and_raise InjectedError, "injected error"
      end

      it "does not swallow the exception" do
        expect { validation.call }.to raise_error(InjectedError)
      end
    end
  end

end
