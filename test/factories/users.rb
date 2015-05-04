FactoryGirl.define do
  factory :user do
     sequence(:email) { |n| "user#{n}@example.com" }
     password "1234"
  end
end
