require 'rails_helper'

describe Event, type: :model do
  subject { build(:event) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'validations' do
    it { expect(subject).to validate_inclusion_of(:event_type).in_array(Event::ALLOWED_TYPES) }
  end

  describe 'scopes' do
    before do
      @product = create(:product)
    end

    it 'aggregates Preview event stats' do
      @event = create(:event, :preview, object_id: @product.id)
      expect(described_class.previews).to include @event
    end

    it 'aggregates Download event stats' do
      @event = create(:event, :download, object_id: @product.id)
      expect(described_class.downloads).to include @event
    end

    it 'aggregates Upload event stats' do
      @event = create(:event, :upload, object_id: @product.id)
      expect(described_class.uploads).to include @event
    end

    it 'aggregates Product event stats' do
      @event = create(:event, object_id: @product.id)
      expect(described_class.products).to include @event
    end
  end
end
