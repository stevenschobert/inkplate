workers Integer(ENV["WEB_CONCURRENCY"] || 2)
threads_count = Integer(ENV["MAX_THREADS"] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
environment ENV["RACK_ENV"] || "development"

bind_host       = ENV["HOST"] || "127.0.0.1"
bind_port       = ENV["PORT"] || 3000
ssl_port        = ENV["SSL_PORT"] || bind_port.to_i + 1
ssl_key_path    = ENV["SSL_KEY_PATH"]
ssl_cert_path   = ENV["SSL_CERT_PATH"]

if ssl_key_path && ssl_cert_path
  bind "ssl://#{ bind_host }:#{ ssl_port }?key=#{ ssl_key_path }&cert=#{ ssl_cert_path }"
end

bind "tcp://#{ bind_host }:#{ bind_port }"

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
