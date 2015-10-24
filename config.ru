require_relative 'bootstrap'

require 'xmlrpc/rack_server'

server = XMLRPC::RackServer.new

# mount any xml api implementations in their
# respective namespace
Api::XMLRPC.implementations.each do |impl|
  server.add_handler(XMLRPC.iPIMethods(impl[:namespace]), impl[:klass].new)
end

run server

