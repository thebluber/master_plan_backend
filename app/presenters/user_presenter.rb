require 'roar/decorator'
require 'roar/json'

module UserPresenter
  include Roar::JSON
  property :email
end
