#Master Plan API back-end
This is the API back-end of the project Master Plan which helps you to organize tasks, achieve goals and motivate yourself.
##API
The API is implemented using Rails and Grape and returns JSON responses.
####User Registration and Sign In, Sign Out
```ruby
#registration
post /api/v1/users/sign_up user: { email: 'user@example.de', password: '1234' }
#=> 201

#sign in
post /api/v1/users/sign_in user: { email: 'user@example.de', password: '1234' }
#=> { email: 'user@example.de' }

#sign out
delete /api/v1/users/sign_out
#=> 200
```

####User Session
User authentication required.
```ruby
#get current user
get /api/v1/session
#=> { email: 'user@example.de' }
```

####User Tasks
User authentication required.
A task is defined by following properties:
- id Integer
- description String
- flag (0: daily, 1: weekly, 2: monthly, 3: onetime) Integer
- category Integer
- goal Integer [optional]
- deadline Date [optional]
- done Boolean
- completed Boolean
The difference between done and completed is, done refers to a given date and completed is used in general.
For example a periodic task could be done for today but not yet completed for the period.

```ruby
#get all tasks of current user
get /api/v1/tasks
#=> [ task1, task2, ...]

#get tasks of current user on a specific date
get /api/v1/tasks/for_date/2015-06-12
#=> [ task1, task2, ...]

#create a new task
post /api/v1/tasks { description: 'MyTask', category_id: 1, flag: 0, deadline: '2015-06-12', goal_id: 2 }
#=> { id: 1, description: 'MyTask', category_id: 1, flag: 0, deadline: '2015-06-12', goal_id: 2, completed: false }

#get a task
get /api/v1/tasks/1
#=> { id: 1, description: 'MyTask', category_id: 1, flag: 0, deadline: '2015-06-12', goal_id: 2, completed: false }

#update a task
put /api/v1/tasks/1 { description: 'NewName', deadline: '2015-06-13' }
#=> { id: 1, description: 'NewName', category_id: 1, flag: 0, deadline: '2015-06-13', goal_id: 2, completed: false }

#mark task as done for a given date
post /api/v1/tasks/1/check_for_date/2015-06-13
#=> 201

#mark task as undone for a given date
delete /api/v1/tasks/1/uncheck_for_date/2015-06-13
#=> 200

#delete task
delete /api/v1/tasks/1
#=> 200
```

####User Goals
User authentication required.
A goal is defines by following properties:
- id Integer
- title String
- description String [optional]
- deadline Date [optional]
- expired Boolean
```ruby
#get all goals
get /api/v1/goals
#=> [goal1, goal2, ...]

#create a new goal
post /api/v1/goals { title: 'Sport', description: 'Do some sport to keep myself fit' }
#=> { id: 1, title: 'Sport', description: 'Do some sport to keep myself fit', deadline: null, expired: false }

#get a goal
get /api/v1/goals/1
#=> { id: 1, title: 'Sport', description: 'Do some sport to keep myself fit', deadline: null, expired: false }

#update a goal
put /api/v1/goals/1 { title: 'NewTitle' }
#=> { id: 1, title: 'NewTitle', description: 'Do some sport to keep myself fit', deadline: null, expired: false }

#delete a goal
delete /api/v1/goals/1
#=> 200
```
####User Categories
User authentication required.
A category is defined by following properties:
- id Integer
- name String
```ruby
#get all categories
get /api/v1/categories
#=> [cat1, cat2, ...]

#create new category
post /api/v1/categories { name: 'personal' }
#=> { id: 1, name: 'personal' }

#get category
get /api/v1/categories/1
#=> { id: 1, name: 'personal' }

#update category
put /api/v1/categories/1 { name: 'private' }
#=> { id: 1, name: 'private' }

#delete category
delete /api/v1/categories/1
#=> 200
```
##TODO
Planed features:
- User can link category to an icon e.g. from Font Awesome https://fortawesome.github.io/Font-Awesome/icons/
