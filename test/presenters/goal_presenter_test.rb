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
    tasks = 4.times.to_a.map{ create(:task, goal: goal).extend(TaskPresenter).to_hash }

    represented_goal = goal.extend(GoalPresenter).to_hash

    simple_fields.each do |field|
      assert_equal represented_goal[field], goal.send(field)
    end

    assert_equal represented_goal['tasks'], tasks
  end

  should 'represent expired 1 (true) or zero (false)' do
    goal = create :goal, deadline: Date.today - 1
    assert_equal goal.extend(GoalPresenter).to_hash['expired'], 1

    goal = create :goal, deadline: Date.today + 1
    assert_equal goal.extend(GoalPresenter).to_hash['expired'], 0
  end
end
