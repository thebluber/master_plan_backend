class API::V1::UsersTest < ActionController::TestCase
  include Rack::Test::Methods
  def app
    Rails.application
  end

  context "user login" do
    setup do
      @user = create(:user)
    end

    should "sign in via api" do
      post "/api/v1/users/sign_in", user: { email: @user.email, password: "1234" }
      assert last_response.ok?
      post "/api/v1/users/sign_in", user: { email: @user.email, password: "12345" }
      assert_not last_response.ok? #401
      post "/api/v1/users/sign_in", user: { email: "admin@test.de", password: "12345" }
      assert_not last_response.ok? #401
    end

    should "sign out via api" do
      sign_in @user
      delete "/api/v1/users/sign_out"
      assert last_response.ok?

      delete "/api/v1/users/sign_out"
      assert last_response.ok?
    end
  end
end
