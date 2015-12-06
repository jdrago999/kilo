
FactoryGirl.define do
  factory :bond do
    association :exchange
    association :channel
  end
end
