
FactoryGirl.define do
  factory :user do
    username { SecureRandom.hex(8) }
    password { 'password' }
  end
end
