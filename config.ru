require_relative 'bootstrap'

require 'rack/json_server'
require 'rack/xmlrpc_server'

server = Proc.new { |env| [200, {}, []] }

use JsonServer
use XmlRpcServer

run server

