class Goal < ActiveRecord::Base
  belongs_to :user
  has_many :tasks
  validates :title, :user, presence: true
  after_create :set_deadline

  private
  #default deadline should be 1 year after the creation of the goal
  def set_deadline
    self.deadline ||= self.created_at.advance(years: 1)
  end
end
