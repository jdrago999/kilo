
FactoryGirl.define do
  factory :channel do
    association :vhost
    name { SecureRandom.hex(8) }
  end
end
