require 'zendesk_api'

class TicketsController < ApplicationController

  def index
    @tickets = []
    @total_tickets = nil
    @current_page = params[:page].to_i || nil
    @per_page = 25

    response = ZendeskApi.get_tickets(per_page: @per_page, page: (params[:page] || 1), sort_by: :created_at)

    if(response.error?)
      flash[:error] = error_msg
    else
      @tickets = response.data['tickets']
      @total_tickets = response.data['count']
      @total_pages = (@total_tickets.to_f / @per_page).ceil
    end
  end

  def show
    @ticket = nil

    response = ZendeskApi.get_ticket(params[:id])

    if(response.error?)
      flash[:error] = error_msg
    else
      @ticket = response.data['ticket']
    end
  end

  private
    def error_msg
      "Oops! There was an error getting the ticket data, please try again.
      If this error continues, contact your system administrator."
    end
end
