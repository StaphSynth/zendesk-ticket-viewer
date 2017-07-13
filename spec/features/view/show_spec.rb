require 'rails_helper'

RSpec.feature 'Show', type: :feature do
  scenario 'View individual ticket details' do
    visit '/ticket?id=1'

    expect(page).to have_text('Ticket #1')
    expect(page).to have_selector('.ticket-container', count: 1)
  end
end
