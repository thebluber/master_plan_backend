require 'test_helper'

class GoalTest < ActiveSupport::TestCase
  should validate_presence_of(:title)
  should belong_to(:user)
  should have_many(:tasks)
  should_not allow_value(" ").for(:title)
end
