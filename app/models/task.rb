class Task < ActiveRecord::Base
  belongs_to :user
  belongs_to :goal
  belongs_to :category
  has_many :done_tasks
  validates :user, :category, :flag, :description, presence: true
  #flag should be one of following:
  #0: daily
  #1: weekly
  #2: monthly
  #3: onetime
  validates :flag, inclusion: { in: 0..3 }

  def done?(date)
    return false if self.done_tasks.empty?
    case self.flag
    when 3
      return !self.done_tasks.empty?
    when 0
      return !self.done_tasks.where(year: date.year, month: date.month, cweek: date.cweek, cwday: date.cwday).empty?
    when 1
      return !self.done_tasks.where(year: date.year, month: date.month, cweek: date.cweek).empty?
    when 2
      return !self.done_tasks.where(year: date.year, month: date.month).empty?
    end
  end
end
