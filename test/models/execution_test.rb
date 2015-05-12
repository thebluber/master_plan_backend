require 'test_helper'

class ExecutionTest < ActiveSupport::TestCase
  should belong_to(:task)
  context "creation date" do
    setup do
      time = Time.local(2015, 5, 4, 18, 0, 0)
      @execution = create(:execution, created_at: time)
    end

    should "set cwday, cweek, month and year according to the creation date" do
      assert_equal @execution.cwday, 1
      assert_equal @execution.cweek, 19
      assert_equal @execution.month, 5
      assert_equal @execution.year, 2015
    end
  end
end
