require 'test_helper'

class DoneTaskTest < ActiveSupport::TestCase
  should belong_to(:task)
  context "creation date" do
    setup do
      time = Time.local(2015, 5, 4, 18, 0, 0)
      Timecop.freeze(time)
      @done = create(:done_task)
      Timecop.return
    end

    should "set cwday, cweek, month and year according to the creation date" do
      assert_equal @done.cwday, 1
      assert_equal @done.cweek, 19
      assert_equal @done.month, 5
      assert_equal @done.year, 2015
    end
  end
end
