class Category < ActiveRecord::Base
  belongs_to :user, inverse_of: :categories
  has_many :tasks
  validates :user, :name, presence: true
end
