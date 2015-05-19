require 'test_helper'

class UserPresenterTest < ActiveSupport::TestCase
  should "represent email" do
    user = build :user
    represented_user = user.extend(UserPresenter).to_hash

    assert_equal represented_user['email'], user.send('email')
  end

end
