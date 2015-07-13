require 'roar/decorator'
require 'roar/json'

module TaskPresenter
  include Roar::JSON

  property :id
  property :description
  property :type
  property :category, extend: CategoryPresenter, class: Category
  property :goal, class: Goal do
    property :id
    property :title
  end
  property :deadline
  property :done, skip_render: lambda { |object, args| args[:date].nil? }, getter: lambda { |args| args[:date] ? self.done?(args[:date]) : nil }
  property :completed

  def completed
    represented.completed?
  end

  def type
    flags = ["daily", "weekly", "monthly", "onetime"]
    flags[represented.flag]
  end
end
