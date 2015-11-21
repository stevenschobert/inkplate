require_relative 'bootstrap'

require 'rack/json_server'
require 'rack/xmlrpc_server'

server = Proc.new { |env| [200, {}, []] }

logger = Logger.new('log/requests.log')

use Rack::CommonLogger, logger
use Rack::Logger

use JsonServer
use XmlRpcServer

run server

