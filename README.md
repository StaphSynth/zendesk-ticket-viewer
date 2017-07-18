# README

### Setup instructions
* Make sure you have Ruby >= v2.3.1 installed
* Clone the repo, then
`$ cd path/to/repo`
* Run bundle install
`$ bundle install`
* Generate a new secret key and add it to the Rails secrets file
`$ rake secret`
  * Copy the output of `rake secret` and paste it into the `secret_key_base` of `{repo_name}/config/secrets.example.yml`
  * You will then need to change the email and subdomain sections to conform to a Zendesk Account
  * Change the name of the file to `secrets.yml`
* `$ rails s`
* Point your browser to `localhost:3000`

### Running the test suite
Assuming you have set up the secrets file described above, then simply `$ bundle exec rspec`
