class API::V1::UsersTest < ActionController::TestCase
  include APITest
  context "user login" do
    setup do
      @user = create(:user)
    end

    should "sign in via api" do
      post "#{@@API_ROOT}/users/sign_in", user: { email: @user.email, password: "1234" }
      assert last_response.ok?
      post "#{@@API_ROOT}/users/sign_in", user: { email: @user.email, password: "12345" }
      assert_equal last_response.status, 401
      assert_equal(JSON.parse(last_response.body), {"error" => "Wrong email address or password"})
      post "#{@@API_ROOT}/users/sign_in", user: { email: "admin@test.de", password: "12345" }
      assert_equal last_response.status, 401
      assert_equal(JSON.parse(last_response.body), {"error" => "Wrong email address or password"})
    end

    should "sign out via api" do
      sign_in @user
      delete "#{@@API_ROOT}/users/sign_out"
      assert last_response.ok?

      delete "#{@@API_ROOT}/users/sign_out"
      assert last_response.ok?
    end
  end
end
