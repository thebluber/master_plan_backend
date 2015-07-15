require 'test_helper'

class UserPresenterTest < ActiveSupport::TestCase
  should "represent email" do
    user = build :user
    represented_user = user.extend(UserPresenter).to_hash

    assert_equal represented_user['email'], user.send('email')
  end

  should "represent the goals and categories" do
    user = create :user
    goal = create :goal, user: user

    represented_user = user.extend(UserPresenter).to_hash

    assert_equal represented_user['goals'], [{ "id" => goal.id, "title" => goal.title }]
    assert_equal represented_user['categories'], [{"id"=>1, "name"=>"work"}, {"id"=>2, "name"=>"personal"}, {"id"=>3, "name"=>"miscellaneous"}]
  end

end
