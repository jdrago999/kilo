# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.find_by(username: 'kilo') || User.create!( username: 'kilo', password: 'password', password_confirmation: 'password')

vhost = Vhost.find_by(name: 'kilo') || Vhost.create!( name: 'kilo')

unless user.vhosts.map(&:name).include? 'kilo'
  user.vhost_users.create( vhost: vhost, conf: true, read: true, write: true )
end
