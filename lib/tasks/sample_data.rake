require 'faker'

namespace :db do
  desc 'Fill database with sample data'
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    make_users
    make_microposts
    make_relationships

  end
end

def make_users
  admin = User.create!(:name                  => 'Example User',
                       :email                 => 'example@railstutorial.org',
                       :password              => 'foobar',
                       :password_confirmation => 'foobar')
  admin.toggle!(:admin)
  99.times do |i|
    name     = Faker::Name.name
    email    = "example-#{i+1}@railstutorial.org"
    password = 'password'
    User.create!(:name                  => name,
                 :email                 => email,
                 :password              => password,
                 :password_confirmation => password)
  end
end

def make_microposts
  User.find(:all, :limit => 6).each do |user|
    50.times {|i| user.microposts.create!(:content => Faker::Lorem.sentence(5))}
  end
end

def make_relationships
  users = User.all
  user  = users.first
  following = users[1..50]
  followers = users[3..40]
  following.each {|followed| user.follow!(followed)}
  followers.each {|follower| follower.follow!(user)}
end
