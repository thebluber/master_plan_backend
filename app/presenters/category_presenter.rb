require 'roar/decorator'
require 'roar/json'

module CategoryPresenter
  include Roar::JSON

  property :id
  property :name
end
