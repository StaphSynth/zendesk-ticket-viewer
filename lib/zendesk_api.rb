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

    #appends more tickets to the tickets array if present
    #accepts a Response object and will append the arg's tickets
    def append_tickets(response)
      return unless(@data['tickets'] && response.is_a?(Response) && response.data['tickets'])

      @data['tickets'].concat(response.data['tickets'])
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

  #gets tickets from the ZD API. By default ZD API returns max 100 tickets,
  #so call repeatedly to get everything. Accepts an optional query string, but
  #can be expanded to accept an optional hash containing query string params
  def self.get_tickets(query = nil)
    extension = 'tickets.json'

    extension += query if(query && query.is_a?(String))

    response = HTTParty.get(credentials[:url] + extension, basic_auth: credentials[:auth])
    Response.new(response)
  end

  #retrieves all tickets from the API by repeatedly calling get_tickets
  #until there aren't any more to get. Returns a Response object
  def self.get_all_tickets
    tickets = get_tickets
    return tickets if tickets.error?

    url = tickets.data['next_page']

    while(url) do
      query = '?' + url.split('?')[1]
      next_batch = get_tickets(query)

      return next_batch if next_batch.error?

      tickets.append_tickets(next_batch)
      url = next_batch.data['next_page']
    end

    return tickets
  end
end
