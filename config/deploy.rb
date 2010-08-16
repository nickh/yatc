set :application, "yatc"
set :scm, :git
set :repository,  "git@github.com:nickh/yatc.git"
set :deploy_via, :remote_cache
set :use_sudo, false

server "nicreation.hengeveld.com", :app, :web, :db, :primary => true

# Deploy rules for Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :deploy do
  desc "Run bundler command for installing gems"
  task :bundler, :roles => :app do
    run "cd #{current_path}; bundle install"
  end
end

after("deploy:update_code", "deploy:bundler")

set :deploy_to, "/home/nickh/apps/yatc"

# taken from http://rvm.beginrescueend.com/integration/capistrano/
set :rvm_type, :user                      # we have RVM in home dir, not system-wide install
$:.unshift("#{ENV["HOME"]}/.rvm/lib")     # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, 'ruby-1.9.2'        # Or whatever env you want it to run in.
