require 'test_helper'

class GoalPresenterTest < ActiveSupport::TestCase
  should 'Represent some fields' do
    simple_fields = %w{
      id
      title
      description
      deadline
      expired
    }

    goal = create :goal
    tasks = 4.times.map{ create(:task, goal: goal) }.extend(TaskPresenter.for_collection)

    represented_goal = goal.extend(GoalPresenter).to_hash

    simple_fields.each do |field|
      assert_equal represented_goal[field], goal.send(field)
    end

    assert_equal represented_goal['tasks'], tasks.to_hash
  end

  should 'represent expired' do
    goal = create :goal, deadline: Date.today - 1
    assert goal.extend(GoalPresenter).to_hash['expired']

    goal = create :goal, deadline: Date.today + 1
    assert_not goal.extend(GoalPresenter).to_hash['expired']

    goal = create :goal
    assert_not goal.extend(GoalPresenter).to_hash['expired']
  end
end
