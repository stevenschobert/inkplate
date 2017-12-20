require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'erb'
require 'active_record'
require 'dotenv'

Dotenv.load

AUTOLOAD_PATHS = [ "app" ]
LOAD_PATH_ADDITIONS = [ "lib" ]

def require_tree(dir, ext: ".rb")
  files = tree_files(dir, ext: ext).compact.uniq.sort

  files.each do |file|
    require_relative file
  end
end

def tree_files(dir, ext: ".rb", files: nil)
  files ||= []

  Dir.foreach(dir) do |x|
    unless x == "." || x == ".."
      path = File.join(dir, x)

      if File.file?(path) && File.extname(path) == ext
        files << path
      elsif File.directory?(path)
        files = tree_files(path, ext: ext, files: files)
      end
    end
  end

  files
end

LOAD_PATH_ADDITIONS.each do |path|
  real_path = File.expand_path(File.join(__dir__, path))

  unless $LOAD_PATH.include?(real_path)
    $LOAD_PATH.unshift(real_path)
  end
end

AUTOLOAD_PATHS.each do |path|
  require_tree path
end


# Standard Config
db_config = ERB.new(File.new("config/database.yml").read)
ActiveRecord::Base.configurations = YAML.load(db_config.result(binding))
ActiveRecord::Tasks::DatabaseTasks.env = ActiveRecord::ConnectionHandling::DEFAULT_ENV.call.to_s
ActiveRecord::Tasks::DatabaseTasks.db_dir = "db"
ActiveRecord::Base.establish_connection
