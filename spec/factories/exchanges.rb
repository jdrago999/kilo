
FactoryGirl.define do
  factory :exchange do
    association :vhost
    name { SecureRandom.hex(8) }
  end
end

