require 'roar/decorator'
require 'roar/json'

module GoalPresenter
  include Roar::JSON

  property :id
  property :title
  property :description
  property :deadline
  property :expired

  collection :tasks, extend: TaskPresenter, class: Task

  def expired
    return deadline < Date.today if deadline
    false
  end

end
