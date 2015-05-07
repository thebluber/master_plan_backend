class API::V1::TasksTest < ActionController::TestCase
  include APITest

  context "authtenticated access" do
    should "abort all unauthenticated accesses" do
      %w{/tasks /tasks/1 /tasks?date=2015-05-06}.each do |w|
        get @@API_ROOT + w
        assert_equal last_response.status, 401
      end

      post "#{@@API_ROOT}/tasks", {}
      assert_equal last_response.status, 401

      put "#{@@APP_ROOT}/tasks/1", {}
      assert_equal last_response.status, 401
    end
  end

  context "/tasks" do
    setup do
      @user = create(:user)
      time = Time.local(2015, 5, 6, 18, 0, 0) #2015-05-06 is a Wednesday
      Timecop.travel(time)
      #onetime
      onetime = create(:task, flag: 3, user: @user)
      #daily
      daily = create(:task, flag: 0, user: @user)
      create(:done_task, task: daily)
      #weekly
      weekly = create(:task, flag: 1, user: @user)
      create(:done_task, task: weekly)
      #monthly
      monthly = create(:task, flag: 2, user: @user)
      create(:done_task, task: monthly)
      Timecop.return
      sign_in @user

      #JSON response body
      @all_tasks = [daily, weekly, monthly, onetime].map do |task|
        {
          "id" => task.id,
          "description" => task.description,
          "goal_id" => task.goal_id,
          "category_id" => task.category_id,
          "deadline" => task.deadline.to_s,
          "done" => task.onetime? ? 0 : 1, #done: 1, undone: 0
          "flag" => task.flag
        }
      end
      tasks20150506 = [daily, weekly, monthly, onetime].map do |task|
        {
          "id" => task.id,
          "description" => task.description,
          "goal_id" => task.goal_id,
          "category_id" => task.category_id,
          "deadline" => task.deadline.to_s,
          "done" => 1, #done: 1, undone: 0
          "flag" => task.flag
        }
      end
      tasks20150507 = [daily, weekly, monthly, onetime].map do |task|
        {
          "id" => task.id,
          "description" => task.description,
          "goal_id" => task.goal_id,
          "category_id" => task.category_id,
          "deadline" => task.deadline.to_s,
          "done" => task.daily? || task.onetime? ? 0 : 1, #done: 1, undone: 0
          "flag" => task.flag
        }
      end
      tasks20150514 = [daily, weekly, monthly, onetime].map do |task|
        {
          "id" => task.id,
          "description" => task.description,
          "goal_id" => task.goal_id,
          "category_id" => task.category_id,
          "deadline" => task.deadline.to_s,
          "done" => task.monthly? ? 1 : 0, #done: 1, undone: 0
          "flag" => task.flag
        }
      end
      tasks20150607 = [daily, weekly, monthly, onetime].map do |task|
        {
          "id" => task.id,
          "description" => task.description,
          "goal_id" => task.goal_id,
          "category_id" => task.category_id,
          "deadline" => task.deadline.to_s,
          "done" => 0,
          "flag" => task.flag
        }
      end
      @tasks = {
        "2015-05-06" => tasks20150506,
        "2015-05-07" => tasks20150507,
        "2015-05-14" => tasks20150514,
        "2015-06-07" => tasks20150607
      }
      @category = create(:category, user: @user)
      @goal = create(:goal, user: @user)
    end

    should "return all tasks of user" do
      get "#{@@APP_ROOT}/tasks"
      assert last_response.ok?
      assert_equal JSON.parse(last_response.body), @all_tasks
    end

    should "return all tasks on the given date" do
      %w{2015-05-06 2015-05-07 2015-05-14 2015-06-07}.each do |date|
        get "#{@@APP_ROOT}/tasks?date=" + date
        assert last_response.ok?
        assert_equal JSON.parse(last_response.body), @tasks[date]
      end
    end

    should "create new task without goal, with deadline" do
      new_task = {
        description: "NewTask",
        flag: 3,
        category_id: @category.id,
        deadline: "2015-10-10"
      }
      post "#{@@APP_ROOT}/tasks", new_task
      assert last_response.ok?
      new_task.each do |k, v|
        assert_equal Task.last[k], new_task[k]
      end
      assert_nil Task.last.goal
      new_task[:id] = Task.last.id
      new_task[:goal_id] = nil
      assert_equal JSON.parse(last_response.body), new_task.stringify_keys
    end

    should "create new task with goal, without deadline" do
      new_task = {
        description: "NewTask1",
        flag: 0,
        category_id: @category.id,
        goal_id: @goal.id
      }
      post "#{@@APP_ROOT}/tasks", new_task
      assert last_response.ok?
      new_task.each do |k, v|
        assert_equal Task.last[k], new_task[k]
      end
      assert_nil Task.last.deadline
      new_task[:id] = Task.last.id
      new_task[:deadline] = nil
      assert_equal JSON.parse(last_response.body), new_task.stringify_keys
    end

    should "not create new task for invalid input params" do
      count = Task.count
      #without description
      post "#{@@APP_ROOT}/tasks", { flag: 0, category_id: @category.id }
      assert_not last_response.ok?
      #without flag
      post "#{@@APP_ROOT}/tasks", { description: "Task", category_id: @category.id }
      assert_not last_response.ok?
      #without category
      post "#{@@APP_ROOT}/tasks", { description: "Task", flag: 0 }
      assert_not last_response.ok?
      #invalid flag
      post "#{@@APP_ROOT}/tasks", { description: "Task", flag: 4, category_id: @category.id }
      assert_not last_response.ok?
      #invalid category
      post "#{@@APP_ROOT}/tasks", { description: "Task", flag: 0, category_id: 100 }
      assert_not last_response.ok?
      #invalid goal
      post "#{@@APP_ROOT}/tasks", { description: "Task", flag: 0, category_id: @category.id, goal_id: 100 }
      assert_not last_response.ok?
      #wrong date format
      post "#{@@APP_ROOT}/tasks", { description: "Task", flag: 0, category_id: @category, deadline: "2015/05/07" }
      assert_not last_response.ok?

      assert_equal Task.count, count
    end
  end

  context "/tasks/:id" do
    setup do
      @user = create(:user)
      @task = create(:task, flag: 3, user: @user)
      sign_in @user
    end
  end
end

