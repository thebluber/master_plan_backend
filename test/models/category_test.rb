require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should belong_to(:user)
  should have_many(:tasks)
end
