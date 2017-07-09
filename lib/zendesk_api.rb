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

  def self.response_builder(response)
    {
      code: response.code,
      message: JSON.parse(response.body)
    }
  end

  def self.get_tickets
    response = HTTParty.get(credentials[:url] + 'tickets.json', basic_auth: credentials[:auth])
    response_builder(response)
  end
end
