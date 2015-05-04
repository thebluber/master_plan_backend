FactoryGirl.define do
  factory :category do
    sequence(:name) {|n| "cat#{n}" }
    user
  end

end
