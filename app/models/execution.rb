class Execution < ActiveRecord::Base
  belongs_to :task
  validates :task, presence: true

  def calendar_date=(date)
    self.cwday = date.cwday
    self.cweek = date.cweek
    self.month = date.month
    self.year = date.year
    self.save
  end
end
