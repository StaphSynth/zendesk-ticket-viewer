module ZendeskApi

  # response class handles server errors and returns
  # server response data to the controller
  class Response
    def initialize(server_response)
      @error = nil
      @data = nil
      body = JSON.parse(server_response.body)

      if(server_response.code != 200)
        @error = {
          code: server_response.code,
          errors: body
        }
        log_error
      else
        @data = body
      end
    end

    attr_reader :data

    def error?
      @error ? true : false
    end

    private
      def log_error
        error = prettify_error

        #log to console
        puts error

        #log to file errors.log
        File.open('log/errors.log', 'a') do |log|
          log.write error
        end
      end

      def prettify_error
        error = ""
        border = "---------------------------------------------------\n"

        error += border
        error += "#{Time.now} Zendesk API Access Error.\nCode: #{@error[:code]}\n"

        @error[:errors].each do |title, body|
          error += "#{title}: #{body}\n"
        end

        error += border
      end
  end #end Response class

  def self.credentials
    {
      url: Rails.application.secrets.ZD_URL,
      auth: {
        username: Rails.application.secrets.ZD_USERNAME,
        password: Rails.application.secrets.ZD_PASSWORD
      }
    }
  end

  #gets tickets from the ZD API. Accepts an optional query string.
  #returns a Response object containing the ticket data
  def self.get_tickets(query = nil)
    extension = 'tickets.json'

    extension += query if(query && query.is_a?(String))

    response = HTTParty.get(credentials[:url] + extension, basic_auth: credentials[:auth])
    Response.new(response)
  end

  #retrieves tickets from the API in chronological order from date of creation
  #accepts optional :page => x and :per_page => y
  #By default, the API returns max 100 tickets, so repeated calls with the page id
  #are required to get all tickets
  def self.get_all_tickets(query_hash = {})
    query = '?sort_by=created_at'

    if(query_hash[:per_page] && query_hash[:per_page].between?(1,100))
      query += "&per_page=#{query_hash[:per_page]}"
    end
    if(query_hash[:page])
      query += "&page=#{query_hash[:page]}"
    end

    tickets = get_tickets(query)
  end
end
