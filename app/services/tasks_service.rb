class TasksService
  def self.fetch_for user, date=nil, order=:flag
    #date must be a date object
    if date
      Task.for_user(user).created_before(date).order(order).incomplete
    else
      user.tasks.order(order)
    end
  end

  def self.create_task_for owner, params
    new_task = owner.tasks.new({
      description: params[:description],
      flag: params[:flag]
    })

    if owner.is_a?(User)

      new_task.category_id = params[:category_id]
      new_task.goal_id = params[:goal_id]
      new_task.deadline = params[:deadline]

    elsif owner.is_a?(Goal)

      new_task.category_id = params[:category_id]
      new_task.user_id = owner.user_id
      #if deadline is not given the new task should have the same deadline as it's goal
      new_task.deadline = params[:deadline] || owner.deadline

    elsif owner.is_a?(Category)

      new_task.goal_id = params[:goal_id]
      new_task.user_id = owner.user_id
      new_task.deadline = params[:deadline]

    end
    new_task
  end
end
