class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :email, :password, presence: true
  validates :password, length: { minimum: 4 }
  has_many :tasks, inverse_of: :user
  has_many :goals, inverse_of: :user
  has_many :categories, inverse_of: :user

  after_create :add_default_categories

  private
  def add_default_categories
    UsersService.create_default_categories(self)
  end
end
