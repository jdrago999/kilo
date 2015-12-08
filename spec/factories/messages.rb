
FactoryGirl.define do
  factory :message do
    association :channel
    data { { random: SecureRandom.uuid }.to_json }
  end
end
