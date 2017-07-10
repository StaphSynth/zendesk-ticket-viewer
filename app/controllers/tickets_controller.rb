require 'zendesk_api'

class TicketsController < ApplicationController

  def index
    @tickets = []
    @next = nil
    @prev = nil

    response = ZendeskApi.get_all_tickets(per_page: 25, page: params[:page])

    if(response.error?)
      flash[:error] = "Oops! There was an error getting the ticket data, please try again.
                      If this error continues, contact your system administrator."
    else
      @tickets = response.data['tickets']
      @next = response.data['next_page']
      @prev = response.data['previous_page']
    end

  end
end
