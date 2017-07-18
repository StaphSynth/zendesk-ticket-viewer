# README
A Rails App for viewing customer support tickets. The App requests tickets from the [Zendesk](https://www.zendesk.com/) Ticket API and displays them to the user. It pages through the ticket list 25 at a time, using the API's pagination support. The user can click on a ticket in the list to see it in more detail.

### Setup instructions
* Make sure you have Ruby >= v2.3.1 and the bundler gem installed
* Clone the repo, then
`$ cd path/to/repo`
* Run bundle install
`$ bundle install`
* Before you can run the app, you will need to generate a new secret key and add it to the Rails secrets file
  * `$ rake secret`
  * Copy the output of `rake secret` and paste it into the `secret_key_base` of `{repo_name}/config/secrets.example.yml`
  * You will then need to change the email, password and subdomain sections to conform to a Zendesk Account
  * Change the name of the secrets file to `secrets.yml`
* Run the test suite `$ bundle exec rspec`
* If the tests pass, then serve the app `$ rails s`
* Point your browser to `localhost:3000`
