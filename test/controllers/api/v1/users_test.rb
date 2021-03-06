require 'test_helper'

class API::V1::UsersTest < ActionController::TestCase
  include API::V1::APITestHelper
  context "user login" do
    setup do
      @user = create(:user)
    end

    should "sign in via api" do
      post "/api/v1/users/sign_in", user: { email: @user.email, password: "1234" }
      assert_equal last_response.status, 201
      post "/api/v1/users/sign_in", user: { email: @user.email, password: "12345" }
      assert_equal last_response.status, 401
      assert_equal(JSON.parse(last_response.body), {"error" => "Wrong email address or password"})
      post "/api/v1/users/sign_in", user: { email: "admin@test.de", password: "12345" }
      assert_equal last_response.status, 401
      assert_equal(JSON.parse(last_response.body), {"error" => "Wrong email address or password"})
    end

    should "sign in and activate remember_me token" do
      post "/api/v1/users/sign_in", user: { email: @user.email, password: "1234", remember_me: true }
      assert_equal last_response.status, 201
      @user.reload
      assert_not @user.remember_created_at.nil?
    end

    should "sign out via api" do
      delete "/api/v1/users/sign_out"
      assert last_response.ok?
    end
  end

  context "user registration" do
    setup do
      @user = { email: "user@example.de", password: "1234" }
    end

    should "sign up new user" do
      post "/api/v1/users/sign_up", { user: @user }
      assert_equal last_response.status, 201
      assert_equal User.last.email, @user[:email]
    end
  end
end
