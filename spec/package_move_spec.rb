require "package_move"

RSpec.describe PackageMove do
  class InjectedError < StandardError; end
  let(:package) { double(:package, id: "myid") }
  let(:id) { package.id }
  let(:source_volume) { double(:source_volume) }
  let(:dest_volume) { double(:dest_volume) }
  subject(:move) { described_class.new(id, source_volume, dest_volume) }

  let(:repo) { double(:repo) }
  before(:each) do
    move.repository = repo
  end

  describe "#call" do
    context "when the package exists and can be saved" do
      before(:each) do
        allow(repo).to receive(:find)
          .with(id: id, volume: source_volume)
          .and_return(package)
        allow(repo).to receive(:save)
      end

      it "saves the package to the dest volume" do
        expect(repo).to receive(:save).with(package: package, volume: dest_volume )
        move.call
      end

      it "returns success" do
        expect(move.call).to eql(Chipmunk::Status.success)
      end
    end

    context "when the package exists but the save fails" do
      before(:each) do
        allow(repo).to receive(:find)
          .with(id: id, volume: source_volume)
          .and_return(package)
        allow(repo).to receive(:save)
          .and_raise InjectedError, "injected error"
      end

      it "does not swallow the exception" do
        expect { move.call }.to raise_error(InjectedError)
      end
    end

    context "when the package does not exist" do
      before(:each) do
        allow(repo).to receive(:find)
          .with(id: id, volume: source_volume)
          .and_raise InjectedError, "injected error"
      end

      it "does not swallow the exception" do
        expect { move.call }.to raise_error(InjectedError)
      end
    end

  end
end
