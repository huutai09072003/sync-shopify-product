require 'rails_helper'

describe DeletedShop, type: :model do
  subject { build(:deleted_shop) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'callbacks' do
    context 'first time shop deletion' do
      it 'should send shop an exit interview' do
        expect {
          create(:deleted_shop)
        }.to change {
          ActionMailer::Base.deliveries.count
        }.by 1
      end
    end
  end
end
