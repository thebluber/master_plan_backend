class API::V1::TasksTest < ActionController::TestCase
  include API::V1::APITestHelper

  context "authtenticated access" do
    should "abort all unauthenticated accesses" do
      %w{tasks tasks/1 tasks?date=2015-05-06}.each do |w|
        get "/api/v1/#{w}"
        assert_equal last_response.status, 401
      end

      post "/api/v1/tasks", {}
      assert_equal last_response.status, 401

      put "/api/v1/tasks/1", {}
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
      get "/api/v1/tasks"
      assert last_response.ok?
      assert_equal last_response.body, @all_tasks_represented
    end

    should "return all tasks on the given date" do
      skip('Not yet implemented')
      %w{2015-05-06 2015-05-07 2015-05-14 2015-06-07}.each do |date|
        get "/api/v1/tasks?date=" + date
        assert last_response.ok?
        assert_equal JSON.parse(last_response.body), @tasks[date]
      end
    end

    should "create new task without goal, with deadline" do
      skip('Not yet implemented')
      new_task = {
        description: "NewTask",
        flag: 3,
        category_id: @category.id,
        deadline: "2015-10-10"
      }
      post "/api/v1/tasks", new_task
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
      skip('not yet implemented')
      new_task = {
        description: "NewTask1",
        flag: 0,
        category_id: @category.id,
        goal_id: @goal.id
      }
      post "/api/v1/tasks", new_task
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
      post "/api/v1/tasks", { flag: 0, category_id: @category.id }
      assert_not last_response.ok?
      #without flag
      post "/api/v1/tasks", { description: "Task", category_id: @category.id }
      assert_not last_response.ok?
      #without category
      post "/api/v1/tasks", { description: "Task", flag: 0 }
      assert_not last_response.ok?
      #invalid flag
      post "/api/v1/tasks", { description: "Task", flag: 4, category_id: @category.id }
      assert_not last_response.ok?
      #invalid category
      post "/api/v1/tasks", { description: "Task", flag: 0, category_id: 100 }
      assert_not last_response.ok?
      #invalid goal
      post "/api/v1/tasks", { description: "Task", flag: 0, category_id: @category.id, goal_id: 100 }
      assert_not last_response.ok?
      #wrong date format
      post "/api/v1/tasks", { description: "Task", flag: 0, category_id: @category, deadline: "2015/05/07" }
      assert_not last_response.ok?

      assert_equal Task.count, count
    end
  end

  context "/tasks/:id" do
    setup do
      @user = create(:user)
      @task = create(:task, flag: 3, user: @user)
      @represented_task = @task.extend(TaskPresenter).to_json
    end

    should 'return the task with the given id' do
      log_in @user.email, '1234'

      get "/api/v1/tasks/#{@task.id}"

      assert last_response.ok?
      assert_equal last_response.body, @represented_task
    end
  end
end

