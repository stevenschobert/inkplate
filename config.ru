require_relative "bootstrap"

require "rack/json_server"
require "rack/xmlrpc_server"

server = Proc.new { |env| [200, {}, []] }

logger = Logger.new("log/requests.log")

if ENV["FORCE_SSL"]
  require "rack/ssl"
  use Rack::SSL
end

use Rack::CommonLogger, logger
use Rack::Logger

use JsonServer
use XmlRpcServer

run server

