#tests the index action of the Tickets controller via the rendered view

require 'rails_helper'
require 'suite_helper'

RSpec.feature 'Tickets Controller: Index', type: :feature do

  #setup environment
  before(:each) do
    @total_tickets = Viewer.per_page * 5
    @last_page = (@total_tickets / Viewer.per_page.to_f).ceil
    @response_tickets = Mock.tickets_response(Viewer.per_page, @total_tickets)
    FactoryGirl.reload
  end

  #the happy path: a page full of tickets
  scenario "The index action renders a page limit of #{Viewer.per_page} tickets from the API" do

    stub_request(:get, Rails.application.secrets.ZD_URL + Viewer.index).
      with(headers: Mock.req_headers).to_return(status: 200, body: @response_tickets, headers: {})

    visit '/'

    expect(page).to have_text(Viewer.title)
    expect(page).to have_selector('.ticket-gist-container', count: Viewer.per_page)
  end

  #if there are no tickets associated with an account, then it should say so.
  scenario 'The index action displays a message when no tickets are returned by the API' do

    empty_response = {
      tickets: [],
      count: 0,
      next_page: nil,
      previous_page: nil
    }
    empty_response = JSON.generate(empty_response)

    stub_request(:get, Rails.application.secrets.ZD_URL + Viewer.index).
      with(headers: Mock.req_headers).to_return(status: 200, body: empty_response, headers: {})

    visit '/'

    expect(page).to have_text(Viewer.title)
    expect(page).not_to have_selector('.ticket-gist-container')
    expect(page).to have_text('There are no tickets to display.')
  end

  #if the ZD API return code != 200, then the controller should flash an error message
  scenario 'The index action handles an error code returned by the API' do

    fail_response = {
      error: 'InvalidEndpoint',
      description: 'Not found'
    }
    fail_response = JSON.generate(fail_response)

    stub_request(:get, Rails.application.secrets.ZD_URL + Viewer.index).
      with(headers: Mock.req_headers).to_return(status: 404, body: fail_response, headers: {})

    visit '/'

    expect(page).to have_text(Viewer.title)
    expect(page).not_to have_selector('.ticket-gist-container')
    expect(page).to have_text(Viewer.error_msg)
  end

  #if the API is not available, the controller should flash an error message
  scenario 'The index action handles an API timeout error' do

    stub_request(:get, Rails.application.secrets.ZD_URL + Viewer.index).
      with(headers: Mock.req_headers).to_timeout

    visit '/'

    expect(page).to have_text(Viewer.title)
    expect(page).to have_text(Viewer.error_msg)
    expect(page).not_to have_selector('.ticket-gist-container')
  end

  #in an attempt to load a results page that doesn't exist, the controller should redirect to the
  #last available page of results and flash a notice to the user
  scenario 'The index action handles an attempt to request a results page that doesn\'t exist' do

    non_extant_page = @last_page + 1
    bad_request = "tickets.json?page=#{non_extant_page}&per_page=#{Viewer.per_page}&sort_by=created_at"
    good_request = "tickets.json?page=#{@last_page}&per_page=#{Viewer.per_page}&sort_by=created_at"

    initial_response = {
      tickets: [],
      count: @total_tickets,
      next_page: nil,
      previous_page: good_request
    }
    initial_response = JSON.generate(initial_response)

    stub_request(:get, Rails.application.secrets.ZD_URL + bad_request).
      with(headers: Mock.req_headers).to_return(status: 200, body: initial_response, headers: {})

    stub_request(:get, Rails.application.secrets.ZD_URL + good_request).
      with(headers: Mock.req_headers).to_return(status: 200, body: @response_tickets, headers: {})

    visit "/tickets?page=#{non_extant_page}"

    expect(page).to have_text(Viewer.title)
    expect(page).to have_text("There are only #{@last_page} pages of results.")
    expect(page).to have_current_path("/tickets?page=#{@last_page}")
  end

end
