require 'zendesk_api'

class TicketsController < ApplicationController
  #index action: render ticket index list
  def index
    @tickets = []
    @total_tickets = nil
    @current_page = params[:page].to_i || nil
    @per_page = CONFIG['tickets']['per_page']

    begin
      response = ZendeskApi.get_tickets(per_page: @per_page, page: (params[:page] || 1), sort_by: :created_at)
    rescue
      flash[:error] = error_msg
      return
    end

    if response.error?
      flash.now[:error] = error_msg
      return
    end

    @tickets = response.data['tickets']
    @total_tickets = response.data['count']
    @total_pages = (@total_tickets.to_f / @per_page).ceil

    #redirect to last page if user attempts to visit a results page that doesn't exist
    if params[:page].to_i > @total_pages
      redirect_to root_url + "?page=#{@total_pages}"
      flash[:notice] = "There #{@total_pages == 1 ? 'is' : 'are'} only #{@total_pages}
                        #{'page'.pluralize(@total_pages)} of results."
      return
    end

    if @tickets.empty?
      flash.now[:notice] = 'There are no tickets to display.'
      return
    end
  end

  #show action: render individual ticket
  def show
    @ticket = nil

    begin
      response = ZendeskApi.get_ticket(params[:id])
    rescue
      flash[:error] = error_msg
      return
    end

    if response.error?
      redirect_to root_url
      flash[:error] = error_msg
    else
      @ticket = response.data['ticket']
    end
  end

  private

  def error_msg
    'Oops! There was an error getting the ticket data, please try again.
    If this error continues, contact your system administrator.'
  end
end
