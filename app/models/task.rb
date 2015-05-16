class Task < ActiveRecord::Base
  belongs_to :user, inverse_of: :tasks
  belongs_to :goal
  belongs_to :category
  has_many :executions, dependent: :destroy
  validates :user, :category, :flag, :description, presence: true
  #flag should be one of following:
  #0: daily
  #1: weekly
  #2: monthly
  #3: onetime
  validates :flag, inclusion: { in: 0..3 }

  before_save :set_scheduled_executions

  scope :for_user, ->(user) { where user_id: user.id }
  scope :created_before, ->(date) { where("created_at < ?", date + 1) }
  scope :incomplete, -> { select { |task| !task.completed? } }

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
    self.scheduled_executions != 0 && self.executions.count >= self.scheduled_executions
  end

  #Is the task done at the given date
  def done?(date)
    if self.onetime?
      return !self.executions.empty?
    elsif self.daily?
      return !self.executions.where(year: date.year, month: date.month, cweek: date.cweek, cwday: date.cwday).empty?
    elsif self.weekly?
      return !self.executions.where(year: date.year, month: date.month, cweek: date.cweek).empty?
    elsif self.monthly?
      return !self.executions.where(year: date.year, month: date.month).empty?
    end
  end

  #Delete execution for the given date depending on task type
  def delete_execution_for(date)
    executions_for_date = []
    if self.onetime?
      executions_for_date = self.executions
    elsif self.daily?
      executions_for_date = self.executions.where(year: date.year, month: date.month, cweek: date.cweek, cwday: date.cwday)
    elsif self.weekly?
      executions_for_date = self.executions.where(year: date.year, cweek: date.cweek)
    elsif self.monthly?
      executions_for_date = self.executions.where(year: date.year, month: date.month)
    end

    !executions_for_date.empty? && executions_for_date.first.destroy
  end

  private
  def set_scheduled_executions
    calculate_scheduled_executions if self.deadline_changed? || self.scheduled_executions.nil?
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
    else
      self.scheduled_executions = 0
    end
  end
end
