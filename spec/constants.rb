#This file contains constants used a lot in the test specs.
#It still needs to be updated if the site implementation changes,
#but at least the test specs are a little more DRY...

#headers for the mock_api calls
def req_headers
  {
    'Accept'=>'*/*',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Authorization'=>"Basic #{Base64.strict_encode64(Rails.application.secrets.ZD_USERNAME +
    ':' + Rails.application.secrets.ZD_PASSWORD)}",
    'User-Agent'=>'Ruby'
  }
end

#Text constants used by the site
module Site
  def self.title
    'Zendesk Ticket Viewer'
  end

  def self.error_msg
    'Oops! There was an error getting the ticket data, please try again.
    If this error continues, contact your system administrator.'
  end

  def self.index
    'tickets.json?page=1&per_page=25&sort_by=created_at'
  end
end
