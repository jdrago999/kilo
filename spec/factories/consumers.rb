
FactoryGirl.define do
  factory :consumer do
    association :channel
    association :vhost_user
  end
end
