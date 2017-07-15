require 'rails_helper'
require 'suite_helper'

RSpec.feature 'Show', type: :feature do

  #happy path: successful individual ticket view
  scenario 'View individual ticket details' do

    stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets/1.json').
      with(headers: req_headers).to_return(status: 200, body: File.read('spec/mock_data/ticket.json'), headers: {})

    visit '/ticket?id=1'

    expect(page).to have_text('Ticket #1')
    expect(page).to have_selector('.ticket-container', count: 1)
  end

  #if the ZD API return code != 200 when trying to view a ticket,
  #the controller should redirect to root and flash an error message
  scenario 'API returns an error when trying to view ticket' do

    response_body = {
      error: "Internal Server Error",
      description: "Er, the server drank all the wine..."
    }

    stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets/1.json').
      with(headers: req_headers).to_return(status: 500, body: JSON.generate(response_body), headers: {})

    stub_request(:get, Rails.application.secrets.ZD_URL + Site.index).
      with(headers: req_headers).to_return(status: 200, body: File.read('spec/mock_data/tickets.json'), headers: {})

    visit '/ticket?id=1'

    expect(page).to have_current_path('/')
    expect(page).to have_text(Site.title)
    expect(page).to have_selector('.ticket-gist-container', count: 25)
    expect(page).to have_text(Site.error_msg)
  end

  #an attempt to view a ticket that doesn't exist should cause
  #a 404 error and force a redirect to the index page
  scenario 'User attempts to load a ticket that doesn\'t exist' do

    response_body = {
      error: 'RecordNotFound',
      description: 'Not Found'
    }

    stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets/26.json').
      with(headers: req_headers).to_return(status: 404, body: JSON.generate(response_body), headers: {})

    stub_request(:get, Rails.application.secrets.ZD_URL + Site.index).
      with(headers: req_headers).to_return(status: 200, body: File.read('spec/mock_data/tickets.json'), headers: {})

    visit '/ticket?id=26'

    expect(page).to have_current_path('/')
    expect(page).to have_text(Site.title)
    expect(page).to have_selector('.ticket-gist-container', count: 25)
    expect(page).to have_text(Site.error_msg)
  end
end
