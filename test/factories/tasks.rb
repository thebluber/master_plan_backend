FactoryGirl.define do
  factory :task do
    user
    goal
    sequence(:description) { |n| "MyTask#{n}" }
    flag 3
    deadline "2015-05-04"
    category
  end
end
