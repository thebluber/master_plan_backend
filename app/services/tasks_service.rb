class TasksService
  def self.fetch_all_for user, date=nil, order=:flag
    #date must be a date object
    if date
      user.tasks.where("created_at < ?", date + 1).order(order).reject{ |task| task.onetime? && task.done?(date) }
    else
      user.tasks.order(order)
    end
  end

  def self.fetch_one_for user, id
    user.tasks.find_by_id(id)
  end
end
