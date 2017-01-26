# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

roles = Role.create([
                      { title: 'admin' },
                      { title: 'user' }
                    ]) if Role.count == 0

users = User.create([
                      { first_name: 'Admin', last_name: 'User', email: 'admin@example.org', role_id: Role.find_by(title: 'admin').id, password: 'password', password_confirmation: 'password' },
                      { first_name: 'Normal', last_name: 'User', email: 'normal@example.org', role_id: Role.find_by(title: 'user').id, password: 'password', password_confirmation: 'password' }
                    ]) if User.count == 0

test_models = TestModel.create([
                                 { title: 'Test Model 1', body: 'Testing 1 2 3.  I belong to admin.', user_id: 1 },
                                 { title: 'Test Model 2', body: 'Testing 1 2 3.  I belong to normal user.', user_id: 2 },
                                 { title: 'Test Model 3', body: 'Testing 1 2 3.  I also belong to normal user.', user_id: 2 }
                               ]) if TestModel.count == 0
