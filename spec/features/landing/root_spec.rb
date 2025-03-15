require 'rails_helper'

feature 'Landing page', :js => true do
  before do
    visit root_path
  end

  context 'logged out' do
    scenario 'should view signup form' do
      expect(page).to have_text 'Install'
      expect(all('input').count).to eql 1
    end
  end
end
