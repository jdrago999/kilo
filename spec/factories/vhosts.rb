
FactoryGirl.define do
  factory :vhost do
    name { SecureRandom.hex(8) }
  end
end
