
FactoryGirl.define do
  factory :vhost_user do
    association :vhost
    association :user

    # Default to full permissions for testing:
    conf { true }
    read { true }
    write { true }
  end
end
