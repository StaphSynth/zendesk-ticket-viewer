require 'faker'

#defines the FactoryGirl Ticket object (a hash) to be
#used as a mock data object in the test suite
FactoryGirl.define do

  sequence :id do |n|
    n
  end

  factory :ticket, class: Hash do

    id
    status { 'open' }
    requester_id { (rand * 10 ** 12).ceil }
    assignee_id { (rand * 10 ** 12).ceil }
    subject { Faker::Hipster.sentence(4, false, 3) }
    description { Faker::Hipster.paragraph(6, false, 4) }
    tags { Faker::Hipster.words(rand(1..6)) }
    created_at { Time.now.utc.iso8601.to_s }
    updated_at { Time.now.utc.iso8601.to_s }

    initialize_with { attributes }
  end
end
