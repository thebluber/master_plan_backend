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
  property :done, getter: lambda { |args|
    puts args.inspect
    if args[:date] ? self.done?(args[:date]) : self.done?
      1
    else
      0
    end
  }

end
