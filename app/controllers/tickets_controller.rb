class TicketsController < ApplicationController

    def index

      credentials = {
        url: Rails.application.secrets.ZD_URL,
        auth: {
          username: Rails.application.secrets.ZD_USERNAME,
          password: Rails.application.secrets.ZD_PASSWORD
        }
      }
      response = HTTParty.get(credentials[:url], basic_auth: credentials[:auth])

      response = JSON.parse(response.body)

      @tickets = response['tickets']

    end
end
