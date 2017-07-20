#unit tests the ZendeskApi module

require 'zendesk_api'
require 'rails_helper'
require 'suite_helper'

describe 'The ZendeskApi module' do

  context 'The get_ticket method' do

    #happy path getting a ticket from the API
    it 'should return a Response object containing a ticket from the API' do

      response_ticket = Mock.ticket_response

      stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets/1.json').
        with(headers: Mock.req_headers).to_return(status: 200, body: response_ticket, headers: {})

      ticket = ZendeskApi.get_ticket(1)

      expect(ticket.error?).to be(false)
      expect(ticket.data['ticket']['id']).to eq(1)
      expect(ticket.data['ticket']).to eq(JSON.parse(response_ticket)['ticket'])
    end

    #if the API is unavailable, raise an error
    it 'should raise an error on API timeout' do

      stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets/1.json').
        with(headers: Mock.req_headers).to_timeout

      expect { ZendeskApi.get_ticket(1) }.to raise_error(StandardError)
    end

    #if the API is available, but returns an error code, the Response
    #object should handle the error
    it 'should handle the error if the API does not return code 200' do

      response = {
        error: 'RecordNotFound',
        description: 'Not Found'
      }
      response = JSON.generate(response)

      stub_request(:get, Rails.application.secrets.ZD_URL + 'tickets/1.json').
        with(headers: Mock.req_headers).to_return(status: 404, body: response, headers: {})

      ticket = ZendeskApi.get_ticket(1)

      expect(ticket.error?).to be(true)
    end
  end

  context 'The get_tickets method' do

    #happy path getting multiple tickets from the API
    it 'should return a Response object containing an array of tickets from the API' do

      response_tickets = Mock.tickets_response(10, 10)

      stub_request(:get, Rails.application.secrets.ZD_URL + Viewer.index).
        with(headers: Mock.req_headers).to_return(status: 200, body: response_tickets, headers: {})

      tickets = ZendeskApi.get_tickets(page: 1, per_page: Viewer.per_page, sort_by: :created_at)

      expect(tickets.error?).to be(false)
      expect(tickets.data['tickets']).to be_a(Array)
      expect(tickets.data['tickets'].length).to eq(JSON.parse(response_tickets)['tickets'].length)
    end

    #if the API is unavailable, raise an error
    it 'should raise an error on API timeout' do

      stub_request(:get, Rails.application.secrets.ZD_URL + Viewer.index).
        with(headers: Mock.req_headers).to_timeout

      expect {
        ZendeskApi.get_tickets(page: 1, per_page: Viewer.per_page, sort_by: :created_at)
      }.to raise_error(StandardError)
    end

    #if the return code != 200, the Respponse object should handle the error
    it 'should handle the error if the API does not return code 200' do

      response = {
        error: 'Internal Server Error',
        description: 'Something went awry'
      }
      response = JSON.generate(response)

      stub_request(:get, Rails.application.secrets.ZD_URL + Viewer.index).
        with(headers: Mock.req_headers).to_return(status: 500, body: response, headers: {})

      tickets = ZendeskApi.get_tickets(page: 1, per_page: Viewer.per_page, sort_by: :created_at)

      expect(tickets.error?).to be(true)
    end
  end

  #check that when an error occurs, it is actually written to the log file
  context 'Response class error logging' do

    it 'verifies that log/error.log is being written to' do

      response = {
        error: 'Internal Server Error',
        description: 'Something went awry'
      }
      response = JSON.generate(response)

      stub_request(:get, Rails.application.secrets.ZD_URL + Viewer.index).
        with(headers: Mock.req_headers).to_return(status: 500, body: response, headers: {})

      before_error_size = File.size('log/errors.log')
      tickets = ZendeskApi.get_tickets(page: 1, per_page: Viewer.per_page, sort_by: :created_at)
      after_error_size = File.size('log/errors.log')

      expect(tickets.error?).to be(true)
      expect(before_error_size).to be < after_error_size
    end
  end
end
