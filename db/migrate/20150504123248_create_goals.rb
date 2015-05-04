class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.integer :user_id
      t.string :title
      t.string :description
      t.date :deadline

      t.timestamps
    end
  end
end
