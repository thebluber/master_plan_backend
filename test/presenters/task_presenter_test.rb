require 'test_helper'

class TaskPresenterTest < ActiveSupport::TestCase
  should 'Represent some fields' do
    simple_fields = %w{
      id
      description
      flag
      category_id
      goal_id
      deadline
    }

    task = build :task
    represented_task = task.extend(TaskPresenter).to_hash

    simple_fields.each do |field|
      assert_equal represented_task[field], task.send(field)
    end
  end

  should 'represent done as 1 (true) or zero (false)' do
    task = build :task
    task.expects(:done?).returns(true)

    assert_equal task.extend(TaskPresenter).to_hash['done'], 1

    task.expects(:done?).returns(false)
    assert_equal task.extend(TaskPresenter).to_hash['done'], 0

  end
end
