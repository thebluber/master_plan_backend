require 'test_helper'

class GoalTest < ActiveSupport::TestCase
  should validate_presence_of(:title)
  should belong_to(:user)
  should have_many(:tasks)
  should_not allow_value(" ").for(:title)
  context "goal with deadline" do
    setup do
      time = Time.local(2008, 9, 1, 10, 5, 0)
      Timecop.freeze(time)
      @goal_without_d = create(:goal)
      @goal_with_d = create(:goal, deadline: "2015-05-04")
      Timecop.return
    end
    should "generate a default deadline" do
      assert_equal @goal_without_d.deadline.year, 2009
    end
    should "accept the input deadline" do
      assert_equal @goal_with_d.deadline, Date.new(2015,5,4)
    end
  end
end
