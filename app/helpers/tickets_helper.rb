module TicketsHelper
  #returns the number of the next page, given the current page
  #and the total number of ticket pages
  def get_next_page(current_page, total_pages)
    if(!current_page || current_page <= 1)
      return 2
    elsif(current_page && current_page < total_pages)
      return (current_page + 1)
    else
      return nil
    end
  end
end
