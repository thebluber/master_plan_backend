# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = User.create({email: 'user@example.com', password: 'password'})

Task.create({user_id: user.id, description: "Do some sport", category_id: user.categories[1].id, flag: 0})
Task.create({user_id: user.id, description: "Finish the implementation of my awesome project", category_id: user.categories[0].id, flag: 3})
Task.create({user_id: user.id, description: "Send mom a birthday greeting", category_id: user.categories[1].id, flag: 3})
Task.create({user_id: user.id, description: "Physiotherapy", category_id: user.categories[2].id, flag: 1})
