require 'roar/decorator'
require 'roar/json'

module UserPresenter
  include Roar::JSON
  property :email
  collection :goals, class: Goal do
    property :id
    property :title
  end
  collection :categories, class: Category do
    property :id
    property :name
  end
end
