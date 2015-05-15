require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should belong_to(:user)
  should have_many(:tasks)

  context "deletable?" do
    setup do
      @category = create :category
    end

    should "only be deletable if there're no tasks belonging to it" do
      assert @category.deletable?
      create :task, category: @category
      @category.reload
      assert_not @category.deletable?
    end
  end
end
