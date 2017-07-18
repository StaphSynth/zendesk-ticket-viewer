#unit tests the ZendeskApi module

require 'zendesk_api'
require 'rails_helper'
require 'suite_helper'

describe 'The ZendeskApi module' do

  context 'The get_ticket method' do

    #happy path getting a ticket from the API
    it '#get_ticket should return a Response object containing a ticket from the API' do

      response_ticket = Mock.ticket_response

      stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets/1.json').
        with(headers: Mock.req_headers).to_return(status: 200, body: response_ticket, headers: {})

      ticket = ZendeskApi.get_ticket(1)

      expect(ticket).to be_a(ZendeskApi::Response)
      expect(ticket.error?).to be(false)
      expect(ticket.data['ticket']['id']).to eq(1)
      expect(ticket.data['ticket']).to eq(JSON.parse(response_ticket)['ticket'])
    end

    #if the API is unavailable, raise an error
    it 'should raise an error on timeout' do

      stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets/1.json').
        with(headers: Mock.req_headers).to_timeout

      expect { ZendeskApi.get_ticket(1) }.to raise_error(StandardError)
    end
  end

  context 'The get_tickets method' do

    #happy path getting multiple tickets from the API
    it 'should return a Response object containing an array of tickets from the API' do

      response_tickets = Mock.tickets_response(10, 10)

      stub_request(:get, Rails.application.secrets.ZD_URL + Site.index).
        with(headers: Mock.req_headers).to_return(status: 200, body: response_tickets, headers: {})

      tickets = ZendeskApi.get_tickets(page: 1, per_page: Site.per_page, sort_by: :created_at)

      expect(tickets).to be_a(ZendeskApi::Response)
      expect(tickets.error?).to be(false)
      expect(tickets.data['tickets']).to be_a(Array)
      expect(tickets.data['tickets'].length).to eq(JSON.parse(response_tickets)['tickets'].length)
    end

    #if the API is unavailable, raise an error
    it 'should raise an error on timeout' do

      stub_request(:get, Rails.application.secrets.ZD_URL + Site.index).
        with(headers: Mock.req_headers).to_timeout

      expect {
        ZendeskApi.get_tickets(page: 1, per_page: Site.per_page, sort_by: :created_at)
      }.to raise_error(StandardError)
    end
  end
end
