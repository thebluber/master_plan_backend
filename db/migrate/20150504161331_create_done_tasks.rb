class CreateDoneTasks < ActiveRecord::Migration
  def change
    create_table :done_tasks do |t|
      t.integer :task_id
      t.integer :cwday
      t.integer :cweek
      t.integer :month
      t.integer :year

      t.timestamps
    end
  end
end
