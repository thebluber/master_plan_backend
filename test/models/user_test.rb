require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should validate_presence_of(:email)
  should validate_presence_of(:password)
  should validate_length_of(:password).is_at_least(4)
  should_not allow_value(" ").for(:password)
  should have_many(:goals)
  should have_many(:tasks)
  should have_many(:categories)

  context "default categories" do
    setup do
      @user = create :user
    end

    should "have default categories" do
      assert_equal @user.categories.map(&:name), ["work", "personal", "miscellaneous"]
    end
  end
end
