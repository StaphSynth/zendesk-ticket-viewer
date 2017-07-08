require 'zendesk_api'

class TicketsController < ApplicationController

  def index
    @error = nil
    @tickets = []

    data = ZendeskApi.get_tickets

    if(data[:code] != 200)
      @error = data
    else
      @tickets = data[:message]['tickets']
    end
  end
end
