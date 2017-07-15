#tests the navigation links

require 'rails_helper'
require 'constants'

RSpec.feature 'Navigation links', type: :feature do

  #since at the index, you can't go back anywhere...
  scenario 'On displaying the index page, the "back" buttons are disabled' do

    stub_request(:get, Rails.application.secrets.ZD_URL + Site.index).
      with(headers: req_headers).to_return(status: 200, body: File.read('spec/mock_data/tickets.json'), headers: {})

    visit '/'

    expect(page).to have_selector('.navigation', count: 2)
    expect(page).to have_css('a.first.disabled')
    expect(page).to have_css('a.back.disabled')
    all('a.first.disabled').each { |a| expect(a['href']).to eq('#') }
    all('a.back.disabled').each { |a| expect(a['href']).to eq('#') }
  end

  #at the last page, expect the forward links to be disabled
  scenario 'On displaying the last page, the "forward" buttons are disabled' do

    #fill the page with tickets, and set the count to 100 (gives 4 total pages with 25pp)
    response_body = JSON.parse(File.read('spec/mock_data/tickets.json'))
    response_body['count'] = 100

    stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets.json?page=4&per_page=25&sort_by=created_at').
      with(headers: req_headers).to_return(status: 200, body: JSON.generate(response_body), headers: {})

    visit '/?page=4'

    expect(page).to have_selector('.navigation', count: 2)
    expect(page).to have_css('a.last.disabled')
    expect(page).to have_css('a.forward.disabled')
    all('a.forward.disabled').each { |a| expect(a['href']).to eq('#') }
    all('a.last.disabled').each { |a| expect(a['href']).to eq('#') }
  end

  #in a middle page, expect forward and back links to be enabled
  scenario 'On displaying a middle page, the navigation links are enabled and point to the correct URL' do

    #fill page with tickets and set the count and next/prev pointer URLs (scenario is on page 3/5)
    response_body = JSON.parse(File.read('spec/mock_data/tickets.json'))
    response_body['count'] = 125
    response_body['next_page'] = Rails.application.secrets.ZD_URL + 'tickets.json?page=4&per_page=25&sort_by=created_at'
    response_body['previous_page'] = Rails.application.secrets.ZD_URL + 'tickets.json?page=2&per_page=25&sort_by=created_at'

    stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets.json?page=3&per_page=25&sort_by=created_at').
      with(headers: req_headers).to_return(status: 200, body: JSON.generate(response_body), headers: {})

    visit '/?page=3'

    expect(page).to have_selector('.navigation', count: 2)
    expect(page).not_to have_css('a.last.disabled')
    expect(page).not_to have_css('a.forward.disabled')
    expect(page).not_to have_css('a.first.disabled')
    expect(page).not_to have_css('a.back.disabled')
    all('a.forward').each { |a| expect(a['href']).to eq(root_url + '?page=4') }
    all('a.last').each { |a| expect(a['href']).to eq(root_url + '?page=5') }
    all('a.first').each { |a| expect(a['href']).to eq(root_url) }
    all('a.back').each { |a| expect(a['href']).to eq(root_url + '?page=2') }
  end
end
