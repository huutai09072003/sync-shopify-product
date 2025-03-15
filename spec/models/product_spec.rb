require 'rails_helper'

describe Product, type: :model do
  subject { build(:product) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'associations' do
    it { expect(subject).to belong_to(:shop) }
  end

  describe 'validations' do
    it { expect(subject).to validate_uniqueness_of(:external_id).case_insensitive }
  end

  describe 'public methods' do
    before do
      @product = create(:product)
      event = create(:event, :preview, object_id: @product.id)
    end

    it 'should have live previews' do
      expect(@product.preview_count).to eql Event.count
    end
  end
end
