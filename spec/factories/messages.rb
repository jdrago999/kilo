
FactoryGirl.define do
  factory :message do
    data { { random: SecureRandom.uuid }.to_json }
  end
end
