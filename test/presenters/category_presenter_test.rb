require 'test_helper'

class CategoryPresenterTest < ActiveSupport::TestCase
  should 'Represent some fields' do
    simple_fields = %w{
      id
      name
    }

    category = create :category

    represented_category = category.extend(CategoryPresenter).to_hash

    simple_fields.each do |field|
      assert_equal represented_category[field], category.send(field)
    end
  end
end
