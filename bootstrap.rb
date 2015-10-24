require 'rubygems'
require 'bundler/setup'
AUTOLOAD_PATHS = [ "app" ]
LOAD_PATH_ADDITIONS = [ "lib" ]

def require_tree(dir)
  files = tree_files(dir).compact.uniq.sort

  files.each do |file|
    require_relative file
  end
end

def tree_files(dir, files: nil)
  files ||= []

  Dir.foreach(dir) do |x|
    unless x == "." || x == ".."
      path = File.join(dir, x)

      if File.file?(path) && File.extname(path) == ".rb"
        files << path
      else
        files = tree_files(path, files: files)
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
