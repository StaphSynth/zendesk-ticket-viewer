require 'rails_helper'

RSpec.feature 'Show', type: :feature do

  #happy path: successful individual ticket view
  scenario 'View individual ticket details' do

    stub_request(:get, "#{Rails.application.secrets.ZD_URL}tickets/1.json").
      with(headers: api_headers).to_return(status: 200, body: File.read('spec/mock_data/ticket.json'), headers: {})

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

    stub_request(:get, "#{Rails.application.secrets.ZD_URL}tickets/1.json").
      with(headers: api_headers).to_return(status: 500, body: JSON.generate(response_body), headers: {})

    stub_request(:get, "#{Rails.application.secrets.ZD_URL}tickets.json?page=1&per_page=25&sort_by=created_at").
      with(headers: api_headers).to_return(status: 200, body: File.read('spec/mock_data/tickets.json'), headers: {})

    visit '/ticket?id=1'

    expect(page).to have_current_path('/')
    expect(page).to have_text('Zendesk Ticket Viewer')
    expect(page).to have_selector('.ticket-gist-container', count: 25)
    expect(page).to have_text('Oops! There was an error getting the ticket data, please try again.
                              If this error continues, contact your system administrator.')
  end
end
