#This file contains helper functions and definitions
#used in the test suite

#defines static req header and functions
#for mocking external API calls and returns
module Mock
  #headers for the mock_api calls
  def self.req_headers
    {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization' => "Basic #{Base64.strict_encode64(Rails.application.secrets.ZD_USERNAME +
      ':' + Rails.application.secrets.ZD_PASSWORD)}",
      'User-Agent' => 'Ruby'
    }
  end

  #returns a mock ticket GET response for use in the test suite
  def self.ticket_response

    response_data = Hash.new.tap do |hash|
      hash[:ticket] = FactoryGirl.build(:ticket)
    end

    return JSON.generate(response_data)
  end

  #returns a mock tickets GET response for use in the test suite
  #accepts an integer, n, for how many tickets to create
  #accepts an integer, count, for the total number of tickets in the account
  #(obviously, n <= count)
  def self.tickets_response(n, count)

    if n > count
      raise ArgumentError, 'Number of tickets on page cannot be greater than total ticket count'
    end

    response_data = Hash.new.tap do |hash|
      hash[:count] = count
      hash[:tickets] = FactoryGirl.build_list(:ticket, n)
      hash[:next_page] = nil
      hash[:previous_page] = nil
    end

    return JSON.generate(response_data)
  end
end

#static text/path/config used by the ticket viewer
module Viewer
  def self.title
    'Zendesk Ticket Viewer'
  end

  def self.error_msg
    'Oops! There was an error getting the ticket data, please try again.
    If this error continues, contact your system administrator.'
  end

  def self.index
    "tickets.json?page=1&per_page=#{Viewer.per_page}&sort_by=created_at"
  end

  def self.per_page
    CONFIG['tickets']['per_page']
  end
end
