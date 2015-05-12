require 'test_helper'

class API::V1::GoalsTest < ActionController::TestCase
  include API::V1::APITestHelper

  context "authenticated access" do
    should "not allow unauthenticated access" do
      get "/api/v1/goals"
      assert_equal last_response.status, 401

      post "/api/v1/goals", { title: "Goal" }
      assert_equal last_response.status, 401

      get "/api/v1/goals/1"
      assert_equal last_response.status, 401

      put "/api/v1/goals/1", { title: "" }
      assert_equal last_response.status, 401

      post "/api/v1/goals/1/tasks", { description: "", flag: 1, category_id: 1 }
      assert_equal last_response.status, 401
    end
  end

  context "/goals" do
    setup do
      @user = create(:user)
      log_in @user.email, "1234"

      @all_goals_represented = 4.times.map{ create(:goal, user: @user) }.extend(GoalPresenter.for_collection)
    end

    should "GET /goals" do
      get "/api/v1/goals"
      assert last_response.ok?
      assert_equal last_response.body, @all_goals_represented.to_json
    end

    should "POST /goals" do
      new_goal = build(:goal).extend(GoalPresenter)
      new_goal.deadline = "2015-10-10"

      post "/api/v1/goals", { title: new_goal.title, description: new_goal.description, deadline: new_goal.deadline}
      assert_equal last_response.status, 201

      new_goal.id = Goal.last.id
      assert_equal last_response.body, new_goal.to_json
    end

    should "prevent assignment of user_id by create" do
      other_user = create(:user)
      new_goal = build(:goal).extend(GoalPresenter)

      post "/api/v1/goals", { title: new_goal.title, description: new_goal.description, user_id:  other_user.id}
      assert_equal last_response.status, 201
      
      created_goal = Goal.find(JSON.parse(last_response.body)['id'])
      assert_not other_user.goals.include? created_goal
      assert @user.goals.include? created_goal
    end
  end

  context "/goals/:id" do
    setup do
      @user = create(:user)
      log_in @user.email, "1234"

      @goal = create(:goal, user: @user).extend GoalPresenter
    end

    should "handle invalid input" do
      get "/api/v1/goals/1000"
      assert_equal last_response.status, 400

      put "/api/v1/goals/1000"
      assert_equal last_response.status, 400
    end

    should "GET /goals/:id" do
      get "/api/v1/goals/#{@goal.id}"
      assert last_response.ok?
      assert_equal last_response.body, @goal.to_json
    end

    should "PUT /goals/:id" do
      put "/api/v1/goals/#{@goal.id}", { title: "NewTitle", deadline: "2015-05-12" }
      assert last_response.ok?
      @goal.reload
      assert_equal @goal.title, "NewTitle"
      assert_equal @goal.deadline.to_s, "2015-05-12"
      assert_equal last_response.body, @goal.to_json
    end

    should "prevent assignment of user_id by update" do
      other_user = create :user
      put "/api/v1/goals/#{@goal.id}", { user_id: other_user.id }
      assert last_response.ok?
      assert_not other_user.goals.include? @goal
      assert @user.goals.include? @goal
    end
  end

  context "/goals/:id/tasks" do
    setup do
      @user = create(:user)
      log_in @user.email, "1234"

      @goal = create(:goal, user: @user)
      @category = create(:category, user: @user)
      @task = build(:task, category_id: @category.id).extend(TaskPresenter)
    end

    should "POST /goals/:id/tasks" do
      post "/api/v1/goals/#{@goal.id}/tasks", {
        description: @task.description,
        category_id: @task.category_id,
        flag: @task.flag,
        deadline: @task.deadline
      }
      assert_equal last_response.status, 201
      @task.id = Task.last.id
      @task.goal = @goal
      assert_equal last_response.body, @task.to_json
    end
  end
end
