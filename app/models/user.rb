class User < ActiveRecord::Base
  authenticates_with_sorcery!
  validates :email, :password, presence: true
  validates :password, length: { minimum: 4 }
  has_many :tasks
  has_many :goals
  has_many :categories
end
