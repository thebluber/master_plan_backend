require 'test_helper'

class TaskPresenterTest < ActiveSupport::TestCase
  should 'Represent some fields' do
    simple_fields = %w{
      id
      description
      deadline
    }

    task = build :task
    task.scheduled_executions = 0
    represented_task = task.extend(TaskPresenter).to_hash

    simple_fields.each do |field|
      assert_equal represented_task[field], task.send(field)
    end
    
    #flag should be replaced by string
    assert_equal represented_task['type'], 'onetime'

    assert_not task.completed?
    assert_equal represented_task['completed'], task.completed?

    #nested fields
    assert_equal represented_task['category'], task.category.extend(CategoryPresenter).to_hash
    assert_equal represented_task['goal'], {"id" => task.goal_id, "title" => task.goal.title}

  end

  should 'represent done as true or false' do
    task = create :task
    task.expects(:done?).with("2015-05-12").returns(true)

    assert task.extend(TaskPresenter).to_hash(date: "2015-05-12")['done']

    task.expects(:done?).with("2015-05-12").returns(false)
    assert_not task.extend(TaskPresenter).to_hash(date: "2015-05-12")['done']

  end

  should 'not represent done if date is not given' do
    task = create :task
    assert_nil task.extend(TaskPresenter).to_hash['done']
  end
end
