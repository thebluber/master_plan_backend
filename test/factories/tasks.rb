FactoryGirl.define do
  factory :task do
    user
    goal
    sequence(:description) { |n| "MyTask#{n}" }
    flag 3
    deadline "2015-05-04"
    category
  end

  factory :daily, class: Task do
    user
    goal
    sequence(:description) { |n| "MyTask#{n}" }
    flag 0
    deadline "2015-05-04"
    category
  end

  factory :weekly, class: Task do
    user
    goal
    sequence(:description) { |n| "MyTask#{n}" }
    flag 1
    deadline "2015-05-04"
    category
  end

  factory :monthly, class: Task do
    user
    goal
    sequence(:description) { |n| "MyTask#{n}" }
    flag 2
    deadline "2015-05-04"
    category
  end
end
