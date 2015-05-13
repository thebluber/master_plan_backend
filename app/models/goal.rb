class Goal < ActiveRecord::Base
  belongs_to :user, inverse_of: :goals
  has_many :tasks
  validates :title, :user, presence: true

end
