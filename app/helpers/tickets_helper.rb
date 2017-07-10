module TicketsHelper
  #returns the page number specified by the query string in the passed url
  def get_page_number(url)
    return nil unless url

    query = CGI.parse(url.split('?')[1])
    return query['page'][0]
  end
end
