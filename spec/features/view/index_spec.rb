require 'rails_helper'

RSpec.feature 'Index', type: :feature do
  scenario 'View the ticket index page' do
    visit '/'

    expect(page).to have_text('Zendesk Ticket Viewer')
    expect(page).to have_selector('.ticket-gist-container', count: 25)
  end
end
