require 'test_helper'

class TasksServiceTest < ActiveSupport::TestCase
  context "fetch_for" do
    setup do
      @user = create(:user)

      time = Time.local(2015, 5, 6, 18, 0, 0) #2015-05-06 is a Wednesday
      Timecop.travel(time)

      daily = create(:task, flag: 0, user: @user)
      weekly = create(:task, flag: 1, user: @user)
      monthly = create(:task, flag: 2, user: @user)
      onetime_undone = create(:task, flag: 3, user: @user)
      onetime_done = create(:task, flag: 3, user: @user)
      create(:done_task, task: onetime_done)

      Timecop.return

      @tasks = [daily, weekly, monthly, onetime_undone]
    end

    should "return tasks on the given date without done onetime tasks" do
      assert_equal TasksService.fetch_for(@user, "2015-05-06".to_date), @tasks
    end

    should "not return tasks created after the given date" do
      create(:task, flag: 1, user: @user)
      create(:task, flag: 3, user: @user)
      assert_equal TasksService.fetch_for(@user, "2015-05-06".to_date), @tasks
    end
  end
end
