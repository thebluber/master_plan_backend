require 'test_helper'

class CategoriesTest < ActionController::TestCase
  include API::V1::APITestHelper

  context "authenticated access" do
    should "not allow unauthenticated access" do
      get "/api/v1/categories"
      assert_equal last_response.status, 401

      post "/api/v1/categories", { name: "" }
      assert_equal last_response.status, 401

      get "/api/v1/categories/1"
      assert_equal last_response.status, 401

      put "/api/v1/categories/1"
      assert_equal last_response.status, 401

      delete "/api/v1/categories/1"
      assert_equal last_response.status, 401
    end
  end
  
  context "/categories" do
    setup do
      @user = create :user
      @user.categories.extend(CategoryPresenter.for_collection)

      log_in @user.email, "1234"
    end

    should "GET /categories" do
      get "/api/v1/categories"
      assert_equal last_response.body, @user.categories.to_json
    end

    should "POST /categories" do
      post "/api/v1/categories", { name: "newCat" }
      assert_equal JSON.parse(last_response.body)['name'], "newCat"
      @user.reload
      assert @user.categories.map(&:name).include? "newCat"
    end
  end

  context "/categories/:id" do
    setup do
      @user = create :user
      @category = create(:category, user: @user).extend(CategoryPresenter)

      log_in @user.email, "1234"
    end

    should "GET /categories/:id" do
      get "/api/v1/categories/#{@category.id}"
      assert_equal last_response.body, @category.to_json
    end

    should "PUT /categories/:id" do
      put "/api/v1/categories/#{@category.id}", { name: "NewName" }
      assert_equal JSON.parse(last_response.body)['name'], "NewName"
    end

    should "DELETE /categories/:id if category is deletable" do
      task = create :task, category: @category
      @category.reload
      delete "/api/v1/categories/#{@category.id}"
      assert_equal last_response.status, 403

      task.destroy
      @category.reload
      delete "/api/v1/categories/#{@category.id}"
      assert last_response.ok?
      assert_equal @category.tasks, []
    end

    should "not GET, PUT and DELETE category from another user" do
      other = create :category
      get "/api/v1/categories/#{other.id}"
      assert_equal last_response.status, 400

      put "/api/v1/categories/#{other.id}"
      assert_equal last_response.status, 400

      delete "/api/v1/categories/#{other.id}"
      assert_equal last_response.status, 400
    end
  end
end
