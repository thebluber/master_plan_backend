require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  should validate_presence_of(:flag)
  should validate_presence_of(:description)
  should belong_to(:user)
  should belong_to(:category)
  should belong_to(:goal)
  should have_many(:done_tasks)
  should validate_inclusion_of(:flag).in_range(0..3)
  should_not allow_value(4).for(:flag)

  context "done?" do
    setup do
      @onetime = create(:task, flag: 3)

      time = Time.local(2015, 5, 4, 18, 0, 0)
      #2015-05-04 is a monday
      Timecop.travel(time)
      @daily = create(:task, flag: 0)
      create(:done_task, task: @daily)
      @weekly = create(:task, flag: 1)
      create(:done_task, task: @weekly)
      @monthly = create(:task, flag: 2)
      create(:done_task, task: @monthly)
      Timecop.return
    end

    should "find out whether the onetime task is done at given date" do
      assert_not @onetime.done?(Date.today)
      create(:done_task, task: @onetime)
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
end
