require 'zendesk_api'

class TicketsController < ApplicationController

  def index
    @tickets = ZendeskApi.get_tickets['tickets']
  end
end
