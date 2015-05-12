class AddScheduledExecutionsToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :scheduled_executions, :integer
  end
end
