#tests the end-to-end functionality of the site from the user's perspective

RSpec.feature 'End-to-end app test', type: :feature do

  #setup environment
  before(:each) do
    @total_tickets = Viewer.per_page * 5
    @last_page = (@total_tickets / Viewer.per_page.to_f).ceil
    @response_tickets = Mock.tickets_response(Viewer.per_page, @total_tickets)

    #commonly used stubs
    @index_stub = stub_request(:get, Rails.application.secrets.ZD_URL + Viewer.index).
      with(headers: Mock.req_headers).to_return(status: 200, body: @response_tickets, headers: {})
    @last_page_stub = stub_request(:get, Rails.application.secrets.ZD_URL +
      "tickets.json?page=#{@last_page}&per_page=#{Viewer.per_page}&sort_by=created_at").
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
    expect(page).to have_current_path('/tickets/1')
    expect(page).to have_selector('.ticket-container', count: 1)
    expect(page).to have_text('Ticket #1')
  end

  #it's not enough just to know the buttons exist. Do they actually work?
  context 'The user can use the navigation links' do

    #click next
    scenario 'clicking the "forward" link takes you to the next page' do

    stub_request(:get, Rails.application.secrets.ZD_URL + "tickets.json?page=2&per_page=#{Viewer.per_page}&sort_by=created_at").
      with(headers: Mock.req_headers).to_return(status: 200, body: @response_tickets, headers: {})

    visit '/'
    first('a.forward').click

    expect(page).to have_current_path('/tickets?page=2')
    end

    #click last
    scenario 'clicking the "fast-forward" link takes you to the last page' do

      visit '/'
      first('a.last').click

      expect(page).to have_current_path("/tickets?page=#{@last_page}")
    end

    #click back
    scenario 'clicking the "back" link takes you to the previous page' do

      stub_request(:get, Rails.application.secrets.ZD_URL + "tickets.json?page=#{@last_page - 1}&per_page=#{Viewer.per_page}&sort_by=created_at").
        with(headers: Mock.req_headers).to_return(status: 200, body: @response_tickets, headers: {})

      visit "/tickets?page=#{@last_page}"
      first('a.back').click

      expect(page).to have_current_path("/tickets?page=#{@last_page - 1}")
    end

    #click first
    scenario 'clicking the "rewind" link takes you to the first page' do

      visit "/tickets?page=#{@last_page}"
      first('a.first').click

      expect(page).to have_current_path('/tickets?page=1')
    end

    #click the greyed-out links
    scenario 'clicking on a "disabled" link does nothing' do

      #at the root the 'back' links do nothing
      visit '/'
      first('a.first.disabled').click
      expect(page).to have_current_path('/tickets')
      first('a.back.disabled').click
      expect(page).to have_current_path('/tickets')

      #on the last page, the 'forward' links do nothing
      visit "/tickets?page=#{@last_page}"
      first('a.last.disabled').click
      expect(page).to have_current_path("/tickets?page=#{@last_page}")
      first('a.forward.disabled').click
      expect(page).to have_current_path("/tickets?page=#{@last_page}")
    end
  end
end
