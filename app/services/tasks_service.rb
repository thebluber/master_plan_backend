class TasksService
  def self.fetch_for user, date
    #date must be a date object
    user.tasks.where("created_at < ?", date + 1).reject{ |task| task.onetime? && task.done?(date) }
  end
end
