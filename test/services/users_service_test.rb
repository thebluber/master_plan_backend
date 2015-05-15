require 'test_helper'

class UsersServiceTest < ActiveSupport::TestCase
  context "create default categories" do
    setup do
      @user = create :user
    end

    should "create default categories for given user" do
      UsersService.create_default_categories(@user)
      assert_equal @user.categories.map(&:name), ["work", "personal", "miscellaneous"]
    end
  end
end
