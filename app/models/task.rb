class Task < ActiveRecord::Base
  belongs_to :user
  belongs_to :goal
  belongs_to :category
  has_many :executions
  validates :user, :category, :flag, :description, presence: true
  #flag should be one of following:
  #0: daily
  #1: weekly
  #2: monthly
  #3: onetime
  validates :flag, inclusion: { in: 0..3 }

  before_save :set_scheduled_executions

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

  #Is the task completed
  def completed?
    if self.onetime?
      return !self.executions.empty?
    elsif self.scheduled_executions > 0
      #for cyclic tasks with deadline
      return self.executions.count >= self.scheduled_executions
    else
      #for cyclic tasks without deadline
      return false
    end
  end

  #Is the task done at the given date
  def done?(date=nil)
    return false if self.executions.empty?
    if self.onetime?
      return !self.executions.empty?
    elsif date
      if self.daily?
        return !self.executions.where(year: date.year, month: date.month, cweek: date.cweek, cwday: date.cwday).empty?
      elsif self.weekly?
        return !self.executions.where(year: date.year, month: date.month, cweek: date.cweek).empty?
      elsif self.monthly?
        return !self.executions.where(year: date.year, month: date.month).empty?
      end
    else
      #cyclic tasks are never done, if the date is not given
      false
    end
  end

  private
  def set_scheduled_executions
    calculate_scheduled_executions if self.deadline_changed?
  end

  #calculate how many executions a task would have
  #if the deadline is not given the default value for scheduled_executions is 0
  def calculate_scheduled_executions
    if self.onetime?
      self.scheduled_executions = 1
    elsif self.deadline
      #make sure that newly created tasks have a start date
      started_at = self.created_at ? self.created_at.to_date : Date.today
      if self.daily?
        self.scheduled_executions = (self.deadline - started_at).ceil
      elsif self.weekly?
        self.scheduled_executions = ((self.deadline - started_at)/7).ceil
      elsif self.monthly?
        self.scheduled_executions = ((self.deadline - started_at)/30).ceil
      end
    end
  end
end
