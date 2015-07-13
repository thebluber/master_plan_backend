require 'test_helper'

class API::V1::TasksTest < ActionController::TestCase
  include API::V1::APITestHelper

  context "authtenticated access" do
    should "abort all unauthenticated accesses" do
      %w{tasks tasks/1 tasks/for_date/2015-05-06}.each do |w|
        get "/api/v1/#{w}"
        assert_equal last_response.status, 401
      end

      post "/api/v1/tasks", {}
      assert_equal last_response.status, 401

      put "/api/v1/tasks/1", {}
      assert_equal last_response.status, 401

      post "/api/v1/tasks/1/check_for_date/2015-05-06"
      assert_equal last_response.status, 401

      delete "/api/v1/tasks/1/uncheck_for_date/2015-05-06"
      assert_equal last_response.status, 401

      delete "/api/v1/tasks/1"
      assert_equal last_response.status, 401
    end
  end

  context "user with empty tasks" do
    setup do
      @user = create(:user)
      log_in @user.email, "1234"
    end
    should "return empty arrays" do
      get "/api/v1/tasks"
      assert last_response.ok?
      assert_equal last_response.body, "[]"

      get "/api/v1/tasks/for_date/2015-07-08"
      assert last_response.ok?
      assert_equal last_response.body, "[]"
    end
  end

  context "/tasks" do
    setup do
      @user = create(:user)

      time = Time.local(2015, 5, 6, 18, 0, 0) #2015-05-06 is a Wednesday

      #onetime
      onetime = create(:task, user: @user, created_at: time)

      #daily
      daily = create(:daily, user: @user, created_at: time)
      create(:execution, task: daily).calendar_date = time.to_date

      #weekly
      weekly = create(:weekly, user: @user, created_at: time)
      create(:execution, task: weekly).calendar_date = time.to_date

      #monthly
      monthly = create(:monthly, user: @user, created_at: time)
      create(:execution, task: monthly).calendar_date = time.to_date

      log_in @user.email, "1234"

      #JSON response json
      @all_tasks_represented = [daily, weekly, monthly, onetime].extend(TaskPresenter.for_collection)

      @category = create(:category, user: @user)
      @goal = create(:goal, user: @user)
    end

    should "return all tasks of user" do
      get "/api/v1/tasks"
      assert last_response.ok?
      assert_equal last_response.body, @all_tasks_represented.to_json
    end

    should "return all tasks on the given date" do
      %w{2015-05-06 2015-05-07 2015-05-14 2015-06-07}.each do |date|
        get "/api/v1/tasks/for_date/" + date
        assert last_response.ok?
        assert_equal last_response.body, @all_tasks_represented.to_json(date: date.to_date)
      end
    end

    should "create new task without goal, with deadline" do
      new_task = {
        description: "NewTask",
        flag: 3,
        category_id: @category.id,
        deadline: "2015-10-10"
      }
      post "/api/v1/tasks", new_task
      assert_equal last_response.status, 201
      new_task.each do |k, v|
        assert_equal Task.last[k].to_s, new_task[k].to_s
      end
      assert_nil Task.last.goal
    end

    should "create new task with goal, without deadline" do
      new_task = {
        description: "NewTask1",
        flag: 0,
        category_id: @category.id,
        goal_id: @goal.id
      }
      post "/api/v1/tasks", new_task
      assert_equal last_response.status, 201
      new_task.each do |k, v|
        assert_equal Task.last[k].to_s, new_task[k].to_s
      end
      assert_nil Task.last.deadline
    end

    should "not create new task for invalid input params" do
      count = Task.count
      #without description
      post "/api/v1/tasks", { flag: 0, category_id: @category.id }
      assert_equal last_response.status, 400
      assert JSON.parse(last_response.body)["error"].include?("description is missing")

      #without flag
      post "/api/v1/tasks", { description: "Task", category_id: @category.id }
      assert_equal last_response.status, 400
      assert JSON.parse(last_response.body)["error"].include?("flag is missing")

      #without category
      post "/api/v1/tasks", { description: "Task", flag: 0 }
      assert_equal last_response.status, 400
      assert JSON.parse(last_response.body)["error"].include?("category_id is missing")

      #invalid flag
      post "/api/v1/tasks", { description: "Task", flag: 4, category_id: @category.id }
      assert_equal last_response.status, 400
      assert JSON.parse(last_response.body)["error"].include?("flag does not have a valid value")

      #invalid category
      post "/api/v1/tasks", { description: "Task", flag: 0, category_id: 100 }
      assert_equal last_response.status, 400
      assert_equal JSON.parse(last_response.body)["error"], "Couldn't find Category with 'id'=100"

      #invalid goal
      post "/api/v1/tasks", { description: "Task", flag: 0, category_id: @category.id, goal_id: 100 }
      assert_equal last_response.status, 400
      assert_equal JSON.parse(last_response.body)["error"], "Couldn't find Goal with 'id'=100"

      #wrong date format
      post "/api/v1/tasks", { description: "Task", flag: 0, category_id: @category.id, deadline: "2015-20-39" }
      assert JSON.parse(last_response.body)["error"].include?("deadline is invalid")

      assert_equal Task.count, count
    end
  end

  context "/tasks/:id" do
    setup do
      @user = create(:user)
      log_in @user.email, "1234"

      @task = create(:task, flag: 3, user: @user)
      @represented_task = @task.extend(TaskPresenter).to_json

      @goal = create(:goal, user: @user)
      @category = create(:category, user: @user)
    end

    should "return the task with the given id" do

      get "/api/v1/tasks/#{@task.id}"

      assert last_response.ok?
      assert_equal last_response.body, @represented_task
    end

    should "handle id not found error" do

      get "/api/v1/tasks/10000"

      assert_equal last_response.status, 400
      assert_equal JSON.parse(last_response.body)["error"], "Couldn't find Task with 'id'=10000"
    end

    should "update the task with the given id" do

      update = {
        description: "New description",
        flag: 2,
        deadline: "2015-12-30",
        goal_id: @goal.id,
        category_id: @category.id
      }

      put "/api/v1/tasks/#{@task.id}", update

      assert last_response.ok?
      response = JSON.parse(last_response.body)
      assert_equal response["id"], @task.id
      assert_equal response["completed"], false
      assert_equal response["description"], update[:description]
      assert_equal response["type"], "monthly"
      assert_equal response["deadline"], update[:deadline]
      assert_equal response["category"], { "id" =>  @category.id, "name" => @category.name }
      assert_equal response["goal"], { "id" =>  @goal.id, "title" => @goal.title }
    end

    should "delete task" do
      delete "/api/v1/tasks/#{@task.id}"
      assert last_response.ok?
      assert_nil @user.tasks.find_by_id @task.id
    end

    should "not update the task, if the input is invalid" do

      #task not found
      put "/api/v1/tasks/10000", {}
      assert_equal last_response.status, 400
      assert_equal JSON.parse(last_response.body)["error"], "Couldn't find Task with 'id'=10000"

      #invalid deadline
      put "/api/v1/tasks/#{@task.id}", {deadline: "2015-29-12"}
      assert_equal last_response.status, 400

      #invalid flag
      put "/api/v1/tasks/#{@task.id}", {flag: 4}
      assert_equal last_response.status, 400

      #invalid goal
      put "/api/v1/tasks/#{@task.id}", {goal_id: 10000}
      assert_equal last_response.status, 400
      assert_equal JSON.parse(last_response.body)["error"], "Couldn't find Goal with 'id'=10000"

      #invalid category
      put "/api/v1/tasks/#{@task.id}", {category_id: 10000}
      assert_equal last_response.status, 400
      assert_equal JSON.parse(last_response.body)["error"], "Couldn't find Category with 'id'=10000"
    end
  end

  context "/tasks/:id/check_for_date/:date" do
    setup do
      @user = create :user
      log_in @user.email, "1234"

      @task = create :daily, user: @user
    end

    should "create a new execution for the given task and given date" do
      post "/api/v1/tasks/#{@task.id}/check_for_date/2015-05-15"
      assert_equal last_response.status, 201
      assert @task.done? Date.new(2015,5,15)
    end

    should "not create 2 executions for same date" do
      post "/api/v1/tasks/#{@task.id}/check_for_date/2015-05-15"
      assert_equal last_response.status, 201
      post "/api/v1/tasks/#{@task.id}/check_for_date/2015-05-15"
      assert_equal last_response.status, 200
      assert @task.done? Date.new(2015,5,15)
      assert_equal @task.executions.count, 1
    end
  end

  context "/tasks/:id/uncheck_for_date/:date" do
    setup do
      @user = create :user
      log_in @user.email, "1234"

      @task = create :daily, user: @user
      @execution = create :execution, task: @task
      @execution.calendar_date = Date.today

      @monthly = create :monthly, user: @user
      @execution_current = create :execution, task: @monthly
      @execution_current.calendar_date = Date.new(2015,5,15)
      @execution_past = create :execution, task: @monthly
      @execution_past.calendar_date = Date.new(2015,4,1)

      @onetime = create :task, user: @user
      @execution_onetime = create :execution, task: @onetime
      @execution_onetime.calendar_date = Date.today - 365
    end

    should "delete the existing execution on the given date" do
      delete "/api/v1/tasks/#{@task.id}/uncheck_for_date/#{Date.today}"
      assert last_response.ok?
      @task.reload
      assert_nil @task.executions.find_by_id(@execution.id)

      assert_not @task.done? Date.today
    end

    should "delete executions on other date depending on task type" do
      delete "/api/v1/tasks/#{@monthly.id}/uncheck_for_date/#{Date.new(2015,5,1)}"
      assert last_response.ok?
      @monthly.reload
      assert_nil @monthly.executions.find_by_id(@execution_current)
      assert @monthly.executions.include? @execution_past

      delete "/api/v1/tasks/#{@onetime.id}/uncheck_for_date/#{Date.today}"
      assert last_response.ok?
      assert_nil @onetime.executions.find_by_id(@execution_onetime)
    end
  end
end

