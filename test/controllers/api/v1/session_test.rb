require 'test_helper'

class SessionTest < ActionController::TestCase
  include API::V1::APITestHelper

  context "get current session" do
    setup do
      @user = create :user
      @user.extend(UserPresenter)
    end

    should "return current user" do
      log_in @user.email, "1234"
      get "/api/v1/session"
      assert last_response.ok?
      assert_equal last_response.body, @user.to_json
    end
  end
end
