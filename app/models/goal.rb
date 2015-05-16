class Goal < ActiveRecord::Base
  belongs_to :user, inverse_of: :goals
  has_many :tasks
  validates :title, :user, presence: true

  before_destroy :break_association

  private
  def break_association
    self.tasks.map do |task|
      task.goal_id = nil
      task.save
    end
  end
end
