require 'faker'

namespace :db do
  desc 'Fill database with sample data'
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    User.create!(:name                  => 'Example User',
                 :email                 => 'example@railstutorial.org',
                 :password              => 'foobar',
                 :password_confirmation => 'foobar')
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
end
