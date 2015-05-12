FactoryGirl.define do
  factory :task do
    user
    goal
    sequence(:description) { |n| "MyTask#{n}" }
    flag 3
    deadline "2015-05-04"
    category
  end

  factory :daily, parent: :task do
    flag 0
  end

  factory :weekly, parent: :task do
    flag 1
  end

  factory :monthly, parent: :task do
    flag 2
  end
end
