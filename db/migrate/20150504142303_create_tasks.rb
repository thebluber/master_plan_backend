class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :user_id
      t.integer :goal_id
      t.string :description
      t.integer :flag
      t.date :deadline
      t.integer :category_id

      t.timestamps
    end
  end
end
