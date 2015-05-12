class Goal < ActiveRecord::Base
  belongs_to :user
  has_many :tasks
  validates :title, :user, presence: true

end
