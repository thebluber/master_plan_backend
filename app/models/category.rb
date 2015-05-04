class Category < ActiveRecord::Base
  belongs_to :user
  has_many :tasks
  validates :user, :name, presence: true
end
