namespace :db do
  ActiveRecord::Tasks::DatabaseTasks.env = ActiveRecord::ConnectionHandling::DEFAULT_ENV.call.to_s
  config = ActiveRecord::Tasks::DatabaseTasks.current_config

  desc "Creates the database for the current environment"
  task :create do
    ActiveRecord::Tasks::DatabaseTasks.create(config)
  end

  desc "Drops the database for the current environment"
  task :drop do
    ActiveRecord::Tasks::DatabaseTasks.drop(config)
  end

  desc "Migrates the database for the current environment"
  task :migrate do
    ActiveRecord::Tasks::DatabaseTasks.migrate
  end

end
