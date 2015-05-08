require 'roar/decorator'
require 'roar/json'

class TaskPresenter < Roar::Decorator
  include Roar::JSON

  property :id
  property :description
  property :flag
  property :category_id
  property :goal_id
  property :deadline
  #property :done

  def done
    binding.pry
    #args[:date] ? represented.done?(args[:date]) : represented.done?
  end

end
