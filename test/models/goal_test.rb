require 'test_helper'

class GoalTest < ActiveSupport::TestCase
  should validate_presence_of(:title)
  should belong_to(:user)
  should have_many(:tasks)
  should_not allow_value(" ").for(:title)

  context "deletion" do
    setup do
      @goal = create :goal
      @task = create :task, goal: @goal
    end

    should "set break association between goal and it's task after deletion" do
      @goal.destroy
      @task.reload
      assert_nil @task.goal
      assert_nil @task.goal_id
    end
  end
end
