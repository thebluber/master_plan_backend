class TasksService
  def self.fetch_for user, date=nil, order=:flag
    #date must be a date object
    if date
      user.tasks.where("created_at < ?", date + 1).order(order).reject{ |task| task.completed? }
    else
      user.tasks.order(order)
    end
  end
end
