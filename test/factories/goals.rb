FactoryGirl.define do
  factory :goal do
    user
    sequence(:title) { |n| "Goal#{n}" }
    description "MyString"
    deadline nil
  end

end
