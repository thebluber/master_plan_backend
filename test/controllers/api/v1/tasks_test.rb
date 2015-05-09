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

      put "#{@@API_ROOT}/tasks/1", {}
      assert_equal last_response.status, 401
    end
  end

  context "/tasks" do
    setup do
      @user = create(:user)

      time = Time.local(2015, 5, 6, 18, 0, 0) #2015-05-06 is a Wednesday

      #onetime
      onetime = create(:task, flag: 3, user: @user)

      #daily
      daily = create(:task, flag: 0, user: @user)
      create(:done_task, task: daily, created_at: time)

      #weekly
      weekly = create(:task, flag: 1, user: @user)
      create(:done_task, task: weekly, created_at: time)

      #monthly
      monthly = create(:task, flag: 2, user: @user)
      create(:done_task, task: monthly, created_at: time)

      log_in @user.email, "1234"

      #JSON response json
      @all_tasks_represented = [daily, weekly, monthly, onetime].extend(TaskPresenter.for_collection).to_json

      @category = create(:category, user: @user)
      @goal = create(:goal, user: @user)
    end

    should "return all tasks of user" do
      get "#{@@API_ROOT}/tasks"
      assert last_response.ok?
      assert_equal last_response.body, @all_tasks_represented
    end

    should "return all tasks on the given date" do
      %w{2015-05-06 2015-05-07 2015-05-14 2015-06-07}.each do |date|
        get "#{@@API_ROOT}/tasks?date=" + date
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
      post "#{@@API_ROOT}/tasks", new_task
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
      post "#{@@API_ROOT}/tasks", new_task
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
      post "#{@@API_ROOT}/tasks", { flag: 0, category_id: @category.id }
      assert_not last_response.ok?
      #without flag
      post "#{@@API_ROOT}/tasks", { description: "Task", category_id: @category.id }
      assert_not last_response.ok?
      #without category
      post "#{@@API_ROOT}/tasks", { description: "Task", flag: 0 }
      assert_not last_response.ok?
      #invalid flag
      post "#{@@API_ROOT}/tasks", { description: "Task", flag: 4, category_id: @category.id }
      assert_not last_response.ok?
      #invalid category
      post "#{@@API_ROOT}/tasks", { description: "Task", flag: 0, category_id: 100 }
      assert_not last_response.ok?
      #invalid goal
      post "#{@@API_ROOT}/tasks", { description: "Task", flag: 0, category_id: @category.id, goal_id: 100 }
      assert_not last_response.ok?
      #wrong date format
      post "#{@@API_ROOT}/tasks", { description: "Task", flag: 0, category_id: @category, deadline: "2015/05/07" }
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

