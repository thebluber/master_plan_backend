class Execution < ActiveRecord::Base
  belongs_to :task
  validates :task, presence: true
  after_create :set_date
  private
  def set_date
    today = self.created_at.to_date
    self.cwday = today.cwday
    self.cweek = today.cweek
    self.month = today.month
    self.year = today.year
    self.save
  end
end
