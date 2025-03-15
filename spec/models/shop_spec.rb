require 'rails_helper'

describe Shop, type: :model do
  subject { build(:shop) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'associations' do
    it { expect(subject).to have_many(:products) }
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:shopify_domain) }
  end
end
