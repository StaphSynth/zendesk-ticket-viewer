module ZendeskApi

  def self.credentials
    {
      url: Rails.application.secrets.ZD_URL,
      auth: {
        username: Rails.application.secrets.ZD_USERNAME,
        password: Rails.application.secrets.ZD_PASSWORD
      }
    }
  end

  def self.get_tickets
    response = HTTParty.get(credentials[:url] + 'tickets.json', basic_auth: credentials[:auth])
    JSON.parse(response.body)
  end
end
