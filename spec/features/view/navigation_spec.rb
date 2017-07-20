#tests that the navigation links are rendered correctly

require 'rails_helper'
require 'suite_helper'

RSpec.feature 'Navigation links', type: :feature do

  #setup environment
  before(:each) do
    @total_tickets = Viewer.per_page * 5
    @last_page = (@total_tickets / Viewer.per_page.to_f).ceil
    @response_tickets = Mock.tickets_response(Viewer.per_page, @total_tickets)
    @index_stub = stub_request(:get, Rails.application.secrets.ZD_URL + Viewer.index).
      with(headers: Mock.req_headers).to_return(status: 200, body: @response_tickets, headers: {})

    FactoryGirl.reload
  end

  #since at the index, you can't go back anywhere...
  scenario 'On displaying the index page, the "back" buttons are disabled' do

    visit '/'

    expect(page).to have_selector('.navigation', count: 2)
    expect(page).to have_css('a.first.disabled')
    expect(page).to have_css('a.back.disabled')
    all('a.first.disabled').each { |a| expect(a['href']).to eq('#') }
    all('a.back.disabled').each { |a| expect(a['href']).to eq('#') }
  end

  #at the last page, expect the forward links to be disabled
  scenario 'On displaying the last page, the "forward" buttons are disabled' do

    query = "tickets.json?page=#{@last_page}&per_page=#{Viewer.per_page}&sort_by=created_at"

    stub_request(:get, Rails.application.secrets.ZD_URL + query).
      with(headers: Mock.req_headers).to_return(status: 200, body: @response_tickets, headers: {})

    visit "/tickets?page=#{@last_page}"

    expect(page).to have_selector('.navigation', count: 2)
    expect(page).to have_css('a.last.disabled')
    expect(page).to have_css('a.forward.disabled')
    all('a.forward.disabled').each { |a| expect(a['href']).to eq('#') }
    all('a.last.disabled').each { |a| expect(a['href']).to eq('#') }
  end

  #in a middle page, expect forward and back links to be enabled
  scenario 'On displaying a middle page, the navigation links are enabled and point to the correct URL' do

    middle_page = (@last_page / 2).floor
    query = "tickets.json?page=#{middle_page}&per_page=#{Viewer.per_page}&sort_by=created_at"

    stub_request(:get, Rails.application.secrets.ZD_URL + query).
      with(headers: Mock.req_headers).to_return(status: 200, body: @response_tickets, headers: {})

    visit "/tickets?page=#{middle_page}"

    expect(page).to have_selector('.navigation', count: 2)
    expect(page).not_to have_css('a.last.disabled')
    expect(page).not_to have_css('a.forward.disabled')
    expect(page).not_to have_css('a.first.disabled')
    expect(page).not_to have_css('a.back.disabled')
    all('a.forward').each { |a| expect(a['href']).to eq("/tickets?page=#{middle_page + 1}") }
    all('a.last').each { |a| expect(a['href']).to eq("/tickets?page=#{@last_page}") }
    all('a.first').each { |a| expect(a['href']).to eq('/tickets?page=1') }
    all('a.back').each { |a| expect(a['href']).to eq("/tickets?page=#{middle_page - 1}") }
  end
end
