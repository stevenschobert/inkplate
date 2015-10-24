namespace :db do
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

  desc "Dumps the database schema to db/schema.rb"
  task :dump do
    require 'active_record/schema_dumper'

    File.open(ActiveRecord::Tasks::DatabaseTasks.schema_file, "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end

  desc "Loads the database schema from db/schema.rb"
  task :load do
    ActiveRecord::Tasks::DatabaseTasks.load_schema_for(config)
  end

end
