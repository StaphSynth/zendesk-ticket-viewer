require 'rails_helper'
require 'base64'

RSpec.feature 'Index', type: :feature do
  scenario 'View the ticket index page' do

    stub_request(:get, "#{Rails.application.secrets.ZD_URL}tickets.json?page=&per_page=25&sort_by=created_at").
      with(headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization'=>"Basic #{Base64.encode64(Rails.application.secrets.ZD_USERNAME +
        ':' + Rails.application.secrets.ZD_PASSWORD)}".strip!,
        'User-Agent'=>'Ruby'
      }).to_return(status: 200, body: File.read('spec/mock_data/tickets.json'), headers: {})

    visit '/'

    expect(page).to have_text('Zendesk Ticket Viewer')
    expect(page).to have_selector('.ticket-gist-container', count: 25)
  end
end
