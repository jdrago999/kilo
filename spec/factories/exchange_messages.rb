
FactoryGirl.define do
  factory :exchange_message do
    association :exchange
    association :message
  end
end
