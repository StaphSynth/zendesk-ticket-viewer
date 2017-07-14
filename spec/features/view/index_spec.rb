require 'rails_helper'
require 'constants'

RSpec.feature 'Ticket Controller Index', type: :feature do

  #the happy path: a page full of tickets
  scenario 'View the ticket index page full of tickets' do

    stub_request(:get, Rails.application.secrets.ZD_URL + Site.index).
      with(headers: req_headers).to_return(status: 200, body: File.read('spec/mock_data/tickets.json'), headers: {})

    visit '/'

    expect(page).to have_text(Site.title)
    expect(page).to have_selector('.ticket-gist-container', count: 25)
  end

  #if there are no tickets associated with an account, then it should say so.
  scenario 'View the page with no tickets returned by the API' do

    response_body = {
      tickets: [],
      count: 0,
      next_page: nil,
      previous_page: nil
    }

    stub_request(:get, Rails.application.secrets.ZD_URL + Site.index).
      with(headers: req_headers).to_return(status: 200, body: JSON.generate(response_body), headers: {})

      visit '/'

      expect(page).to have_text(Site.title)
      expect(page).not_to have_selector('.ticket-gist-container')
      expect(page).to have_text('There are no tickets to display.')
  end

  #if the ZD API return code != 200, then the controller should flash an error message
  scenario 'View the page when the API has returned an error' do

    response_body = {
      error: 'InvalidEndpoint',
      description: 'Not found'
    }

    stub_request(:get, Rails.application.secrets.ZD_URL + Site.index).
      with(headers: req_headers).to_return(status: 404, body: JSON.generate(response_body), headers: {})

      visit '/'

      expect(page).to have_text(Site.title)
      expect(page).not_to have_selector('.ticket-gist-container')
      expect(page).to have_text(Site.error_msg)
  end

  #in an attempt to load a results page that doesn't exist, the controller should redirect to the
  #last available page of results (in this case, page 1) and flash a notice to the user
  scenario 'Attempt to request a results page that doesn\'t exist' do

    initial_response_body = {
      tickets: [],
      count: 25,
      next_page: nil,
      previous_page: Rails.application.secrets.ZD_URL + Site.index
    }

    stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets.json?page=2&per_page=25&sort_by=created_at').
      with(headers: req_headers).to_return(status: 200, body: JSON.generate(initial_response_body), headers: {})

    stub_request(:get, Rails.application.secrets.ZD_URL + Site.index).
      with(headers: req_headers).to_return(status: 200, body: File.read('spec/mock_data/tickets.json'), headers: {})

    visit '/?page=2'

    expect(page).to have_text(Site.title)
    expect(page).to have_text('There is only 1 page of results.')
    expect(page).to have_current_path('/?page=1')
  end

end
