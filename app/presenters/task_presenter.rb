require 'roar/decorator'
require 'roar/json'

module TaskPresenter
  include Roar::JSON

  property :id
  property :description
  property :flag
  property :category_id
  property :goal_id
  property :deadline
  property :done, getter: lambda { |args| self.done?(args[:date]) }, skip_render: lambda { |object, args| args[:date].nil? }
  property :completed

  def completed
    represented.completed?
  end

end
