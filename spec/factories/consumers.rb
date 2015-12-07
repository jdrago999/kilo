
FactoryGirl.define do
  factory :consumer do
    association :channel
    association :user
  end
end
