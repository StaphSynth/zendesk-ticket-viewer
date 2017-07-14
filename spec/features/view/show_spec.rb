require 'rails_helper'

RSpec.feature 'Show', type: :feature do
  scenario 'View individual ticket details' do

    stub_request(:get, "#{Rails.application.secrets.ZD_URL}tickets/1.json").
      with(headers: api_headers).to_return(status: 200, body: File.read('spec/mock_data/ticket.json'), headers: {})

    visit '/ticket?id=1'

    expect(page).to have_text('Ticket #1')
    expect(page).to have_selector('.ticket-container', count: 1)
  end
end
