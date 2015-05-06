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

  def onetime?
    self.flag == 3
  end

  def daily?
    self.flag == 0
  end

  def weekly?
    self.flag == 1
  end

  def monthly?
    self.flag == 2
  end

  #Is the task done at the given date
  def done?(date=nil)
    return false if self.done_tasks.empty?
    if self.onetime?
      return !self.done_tasks.empty?
    elsif date
      if self.daily?
        return !self.done_tasks.where(year: date.year, month: date.month, cweek: date.cweek, cwday: date.cwday).empty?
      elsif self.weekly?
        return !self.done_tasks.where(year: date.year, month: date.month, cweek: date.cweek).empty?
      elsif self.monthly?
        return !self.done_tasks.where(year: date.year, month: date.month).empty?
      end
    else
      #cyclic tasks are never done, if the date is not given
      false
    end
  end
end
