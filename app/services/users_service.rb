class UsersService
  def self.create_default_categories user
    %w{work personal miscellaneous}.each do |name|
      user.categories.create(name: name)
    end
  end
end
