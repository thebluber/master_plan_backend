require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  should validate_presence_of(:flag)
  should validate_presence_of(:description)
  should belong_to(:user)
  should belong_to(:category)
  should belong_to(:goal)
  should have_many(:executions)
  should validate_inclusion_of(:flag).in_range(0..3)
  should_not allow_value(4).for(:flag)

  context "task types" do
    setup do
      @onetime = create(:task)
      @daily = create(:daily)
      @weekly = create(:weekly)
      @monthly = create(:monthly)
    end

    should "detect the type of task" do
      assert @onetime.onetime?
      assert @daily.daily?
      assert @weekly.weekly?
      assert @monthly.monthly?
    end
  end

  context "done?" do
    setup do
      @onetime = create(:task)

      time = Time.local(2015, 5, 4, 18, 0, 0)
      #2015-05-04 is a monday
      @daily = create(:daily, created_at: time)
      create(:execution, task: @daily).calendar_date = time.to_date
      @weekly = create(:weekly, created_at: time)
      create(:execution, task: @weekly).calendar_date = time.to_date
      @monthly = create(:monthly, created_at: time)
      create(:execution, task: @monthly).calendar_date = time.to_date
    end

    should "find out whether the onetime task is done at given date" do
      assert_not @onetime.done?(Date.today)
      create(:execution, task: @onetime)
      assert @onetime.done?(Date.today)
    end

    should "find out whether the daily task is done at given date" do
      assert @daily.done?(Date.new(2015, 5, 4))
      assert_not @daily.done?(Date.new(2015, 5, 5))
      assert_not @daily.done?(Date.new(2015, 5, 3))
    end

    should "find out whether the weekly task is done at given date" do
      assert @weekly.done?(Date.new(2015, 5, 4))
      assert @weekly.done?(Date.new(2015, 5, 5))
      assert @weekly.done?(Date.new(2015, 5, 10))
      assert_not @weekly.done?(Date.new(2015, 5, 3))
      assert_not @weekly.done?(Date.new(2015, 5, 11))
    end

    should "find out whether the monthly task is done at given date" do
      assert @monthly.done?(Date.new(2015, 5, 4))
      assert @monthly.done?(Date.new(2015, 5, 5))
      assert @monthly.done?(Date.new(2015, 5, 31))
      assert_not @monthly.done?(Date.new(2015, 6, 3))
      assert_not @monthly.done?(Date.new(2015, 4, 3))
    end
  end

  context "calculation for scheduled executions" do
    setup do
      @onetime = create(:task)

      time = Time.local(2015, 5, 4, 18, 0, 0)
      @daily = create(:daily, created_at: time)
      @weekly = create(:weekly, created_at: time)
      @monthly = create(:monthly, created_at: time)
    end

    should "return 1 for onetime tasks" do
      assert_equal @onetime.scheduled_executions, 1
    end

    #Correct representation would be Float::INFINITY but the database type is Integer
    should "return 0 for cyclic tasks without deadline" do
      assert_equal @daily.scheduled_executions, 0
      assert_equal @weekly.scheduled_executions, 0
      assert_equal @monthly.scheduled_executions, 0
    end

    should "return correct value for cyclic tasks with deadline" do
      #daily
      @daily.deadline = "2016-05-04"
      @daily.save
      assert_equal @daily.scheduled_executions, 366

      #weekly
      @weekly.deadline = "2016-05-04"
      @weekly.save
      assert_equal @weekly.scheduled_executions, 53

      #monthly
      @monthly.deadline = "2016-05-04"
      @monthly.save
      assert_equal @monthly.scheduled_executions, 13
    end
  end

  context "completed?" do
    setup do
      @no_deadline = create(:daily, deadline: nil)
      @onetime = create(:task)

      time = Time.local(2015, 5, 4, 18, 0, 0)
      #2015-05-04 is a monday
      @daily = create(:daily, deadline: "2015-06-04", created_at: time)
      @weekly = create(:weekly, deadline: "2015-06-04", created_at: time)
      @monthly = create(:monthly, deadline: "2015-06-04", created_at: time)
    end

    should "return false for cyclic tasks without deadline" do
      create(:execution, task: @no_deadline)
      assert_not @no_deadline.completed?
    end

    should "check whether a onetime task with or without deadline, a cyclic task with a deadline is completed?" do
      assert_not @onetime.completed?
      @onetime.deadline = "2015-10-10"
      assert_not @onetime.completed?
      create :execution, task: @onetime
      assert @onetime.completed?


      assert_not @daily.completed?
      32.times { create :execution, task: @daily }
      assert @daily.completed?

      assert_not @weekly.completed?
      4.times { create :execution, task: @weekly }
      assert_not @weekly.completed?
      4.times { create :execution, task: @weekly }
      assert @weekly.completed?


      assert_not @monthly.completed?
      2.times { create :execution, task: @monthly }
      assert @monthly.completed?
    end
  end

  context "scopes" do
    setup do
      @user = create :user

      @completed = create :daily, user: @user, deadline: Date.today + 1
      2.times { create :execution, task: @completed }

      @daily = create :daily, user: @user, deadline: nil
      @weekly = create :weekly, user: @user, deadline: nil
      @monthly = create :monthly, user: @user, deadline: nil

      @onetime = create :task, user: @user

      #tasks from other user
      @other_daily = create :daily, deadline: nil
      @other_weekly = create :weekly, deadline: nil
    end

    should "return tasks for user" do
      assert_equal Task.for_user(@user), [@completed, @daily, @weekly, @monthly, @onetime]
    end

    should "return tasks created inclusive and before the given date" do
      new_task = create :task, user: @user, created_at: Date.today + 1
      assert_not Task.created_before(Date.today).include?(new_task)
      assert Task.created_before(Date.today + 1).include?(new_task)
    end

    should "return user's tasks incomplete and created_before the given date" do
      assert_equal Task.for_user(@user).created_before(Date.today).incomplete, [@daily, @weekly, @monthly, @onetime]
    end
  end
end
