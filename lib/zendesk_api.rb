module ZendeskApi
  class << self
    #gets a single ticket by ID from the API
    #pass it the id of the ticket to retrieve
    def get_ticket(id)
      extension = "tickets/#{id}.json"
      get_req(extension)
    end

    #retrieves tickets from the API. Accepts an optional hash of query params
    #which are supported by the ZD API.
    #example: get_tickets(page: 2, per_page: 25, sort_by: :created_at)
    def get_tickets(query_hash = {})
      extension = 'tickets.json'

      unless query_hash.empty?
        extension += '?' + query_hash.map { |key, value| "#{key}=#{value}" }.join('&')
        extension = URI.escape(extension)
      end

      get_req(extension)
    end

    private

    #makes the GET request to the ZD API. Returns a Response object with the returned data
    def get_req(extension)
      response = HTTParty.get(credentials[:url] + extension, basic_auth: credentials[:auth])
      Response.new(response)
    end

    def credentials
      {
        url: Rails.application.secrets.ZD_URL,
        auth: {
          username: Rails.application.secrets.ZD_USERNAME,
          password: Rails.application.secrets.ZD_PASSWORD
        }
      }
    end

    # response class handles server errors and returns
    # server response data to the controller
    class Response
      attr_reader :data

      def initialize(server_response)
        @error = nil
        @data = nil
        body = JSON.parse(server_response.body)

        if server_response.code != 200
          @error = {
            code: server_response.code,
            errors: body
          }
          log_error
        else
          @data = body
        end
      end

      def error?
        @error ? true : false
      end

      private

      def log_error
        error = prettify_error

        puts error unless Rails.env.test?
        File.write('log/errors.log', error, mode: 'a')
      end

      def prettify_error
        border = "---------------------------------------------------\n"

        error = border
        error += "#{Time.now} Zendesk API Access Error.\nCode: #{@error[:code]}\n"

        @error[:errors].each do |title, body|
          error += "#{title}: #{body}\n"
        end

        error += border
      end
    end #end Response class
  end
end
