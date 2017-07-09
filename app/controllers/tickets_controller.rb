require 'zendesk_api'

class TicketsController < ApplicationController

  def index
    @tickets = []

    response = ZendeskApi.get_all_tickets

    if(response.error?)
      flash[:error] = "Oops! There was an error getting the ticket data, please try again.
                      If this error continues, contact your system administrator."
    else
      @tickets = response.data['tickets'].paginate(page: params[:page], per_page: 25)
    end

  end
end
