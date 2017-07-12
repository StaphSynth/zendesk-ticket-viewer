module TicketsHelper
  #returns the page number specified by the query string in the passed url
  def get_page_number(url)
    return nil unless url

    query = CGI.parse(url.split('?')[1])
    return query['page'][0]
  end

  def get_last_page_number(ticket_number, tickets_per_page)
    (ticket_number.to_f / tickets_per_page).ceil.to_s
  end
end
