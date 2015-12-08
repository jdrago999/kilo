
FactoryGirl.define do
  factory :consumer_message do
    association :consumer
    association :message
  end
end
