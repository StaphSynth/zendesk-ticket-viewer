require 'rails_helper'

RSpec.feature 'Index', type: :feature do
  scenario 'View the ticket index page' do

    stub_request(:get, "#{Rails.application.secrets.ZD_URL}tickets.json?page=1&per_page=25&sort_by=created_at").
      with(headers: api_headers).to_return(status: 200, body: File.read('spec/mock_data/tickets.json'), headers: {})

    visit '/'

    expect(page).to have_text('Zendesk Ticket Viewer')
    expect(page).to have_selector('.ticket-gist-container', count: 25)
  end
end
