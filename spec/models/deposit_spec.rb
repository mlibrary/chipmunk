require "rails_helper"

RSpec.describe Deposit, type: :model do
  it_behaves_like "a depositable item" do
    let(:instance) { Fabricate.build(:deposit) }
  end

  it "has a valid fabricator" do
    expect(Fabricate.create(:deposit)).to be_valid
  end

  it "has a valid fabriactor that doesn't save to the database" do
    expect(Fabricate.build(:deposit)).to be_valid
  end

end
