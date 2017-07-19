#tests the end-to-end functionality of the site from the user's perspective

RSpec.feature 'End-to-end app test', type: :feature do

  #setup environment
  before(:each) do
    @total_tickets = Viewer.per_page * 5
    @last_page = (@total_tickets / Viewer.per_page.to_f).ceil
    @response_tickets = Mock.tickets_response(Viewer.per_page, @total_tickets)
    @index_stub = stub_request(:get, Rails.application.secrets.ZD_URL + Viewer.index).
      with(headers: Mock.req_headers).to_return(status: 200, body: @response_tickets, headers: {})
    FactoryGirl.reload
  end

  scenario 'The user can load the ticket list and click on a ticket to show its details' do

    stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets/1.json').
      with(headers: Mock.req_headers).to_return(status: 200, body: Mock.ticket_response, headers: {})

    visit '/'

    #verify the index page has tickets to click on
    expect(page).to have_selector('.ticket-gist-container', count: Viewer.per_page)

    #click on the first ticket gist and verify it redirects and renders
    first('.tickets-list a').click
    expect(page).to have_current_path('/ticket?id=1')
    expect(page).to have_selector('.ticket-container', count: 1)
    expect(page).to have_text('Ticket #1')
  end
end
