
FactoryGirl.define do
  factory :channel_message do
    association :channel
    association :message
  end
end
