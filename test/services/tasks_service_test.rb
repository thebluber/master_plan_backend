require 'test_helper'

class TasksServiceTest < ActiveSupport::TestCase
  context "fetch_for" do
    setup do
      @user = create(:user)

      time = Time.local(2015, 5, 6, 18, 0, 0) #2015-05-06 is a Wednesday
      Timecop.travel(time)

      onetime_undone = create(:task, flag: 3, user: @user)
      monthly = create(:task, flag: 2, user: @user)
      daily = create(:task, flag: 0, user: @user)
      weekly = create(:task, flag: 1, user: @user)
      onetime_done = create(:task, flag: 3, user: @user)
      create(:execution, task: onetime_done)

      Timecop.return

      @tasks_for_date = [daily, weekly, monthly, onetime_undone]
    end

    should "return all tasks of user" do
      assert_equal TasksService.fetch_for(@user), @user.tasks.order(:flag)
    end

    should "return tasks on the given date without done onetime tasks ordered by flag" do
      assert_equal TasksService.fetch_for(@user, "2015-05-06".to_date), @tasks_for_date
    end

    should "not return tasks created after the given date" do
      create(:task, flag: 1, user: @user)
      create(:task, flag: 3, user: @user)
      assert_equal TasksService.fetch_for(@user, "2015-05-06".to_date), @tasks_for_date
    end
  end

  context "create_task_for_" do
    setup do
      @user = create :user
      @category = create :category, user: @user
      @goal = create :goal, user: @user

      @params = build(:task, category_id: @category.id, goal_id: @goal.id, deadline: "2015-10-10")
    end

    should "create task from given params for user" do
      task = TasksService.create_task_for @user, @params
      %w{description flag deadline category_id goal_id}.each do |attr|
        assert_equal task.send(attr), @params.send(attr)
      end
      task.save
      assert @user.tasks.include? task
    end

    should "create task from given params for goal" do
      @goal.deadline = "2016-05-08"
      @goal.save
      @params.deadline = nil
      task = TasksService.create_task_for @goal, @params
      %w{description flag category_id goal_id}.each do |attr|
        assert_equal task.send(attr), @params.send(attr)
      end

      #new task inherits the deadline from goal
      assert_equal task.deadline, @goal.deadline
      task.save

      assert @user.tasks.include? task
      assert_equal task.goal, @goal
    end

    should "create task from given params for category" do
      task = TasksService.create_task_for @category, @params
      %w{description flag deadline goal_id}.each do |attr|
        assert_equal task.send(attr), @params.send(attr)
      end

      task.save

      assert @user.tasks.include? task
      assert_equal task.category, @category
    end
  end
end
