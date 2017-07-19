#tests the Show action of the Tickets controller via the rendered view

require 'rails_helper'
require 'suite_helper'

RSpec.feature 'Ticket Controller: Show', type: :feature do

  #setup environment
  before(:each) do
    @total_tickets = Viewer.per_page * 5
    @response_ticket = Mock.ticket_response
    @response_tickets = Mock.tickets_response(Viewer.per_page, @total_tickets)
    FactoryGirl.reload
  end

  #happy path: successful individual ticket view
  scenario 'View individual ticket details' do

    stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets/1.json').
      with(headers: Mock.req_headers).to_return(status: 200, body: @response_ticket, headers: {})

    visit '/ticket?id=1'

    expect(page).to have_text('Ticket #1')
    expect(page).to have_selector('.ticket-container', count: 1)
  end

  #if the ZD API return code != 200 when trying to view a ticket,
  #the controller should redirect to root and flash an error message
  scenario 'API returns an error when trying to view ticket' do

    fail_response = {
      error: "Internal Server Error",
      description: "Er, the server drank all the wine..."
    }
    fail_response = JSON.generate(fail_response)

    stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets/1.json').
      with(headers: Mock.req_headers).to_return(status: 500, body: fail_response, headers: {})

    stub_request(:get, Rails.application.secrets.ZD_URL + Viewer.index).
      with(headers: Mock.req_headers).to_return(status: 200, body: @response_tickets, headers: {})

    visit '/ticket?id=1'

    expect(page).to have_current_path('/')
    expect(page).to have_text(Viewer.title)
    expect(page).to have_selector('.ticket-gist-container', count: Viewer.per_page)
    expect(page).to have_text(Viewer.error_msg)
  end

  #if the API request times out, the controller should display an error message
  scenario 'API times out when trying to view a ticket' do

    stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets/1.json').
      with(headers: Mock.req_headers).to_timeout

    visit '/ticket?id=1'

    expect(page).to have_text(Viewer.error_msg)
    expect(page).not_to have_selector('.ticket-container')
  end

  #an attempt to view a ticket that doesn't exist should cause
  #a 404 error and force a redirect to the index page
  scenario 'User attempts to load a ticket that doesn\'t exist' do

    non_extant_ticket = @total_tickets + 1
    fail_response = {
      error: 'RecordNotFound',
      description: 'Not Found'
    }
    fail_response = JSON.generate(fail_response)

    stub_request(:get, Rails.application.secrets.ZD_URL + "tickets/#{non_extant_ticket}.json").
      with(headers: Mock.req_headers).to_return(status: 404, body: fail_response, headers: {})

    stub_request(:get, Rails.application.secrets.ZD_URL + Viewer.index).
      with(headers: Mock.req_headers).to_return(status: 200, body: @response_tickets, headers: {})

    visit "/ticket?id=#{non_extant_ticket}"

    expect(page).to have_current_path('/')
    expect(page).to have_text(Viewer.title)
    expect(page).to have_selector('.ticket-gist-container', count: Viewer.per_page)
    expect(page).to have_text(Viewer.error_msg)
  end
end
