require 'xmlrpc/server'

# Rack-enabled XMLRPC server
module XMLRPC
  class RackServer < BasicServer

    def call(env)
      req = Rack::Request.new(env)

      data = req.body.read

      # TODO: implement logging
      puts data

      reply = process(data)

      # TODO: implement logging
      puts reply

      [200, { "Content-Type" => "text/xml" }, [reply]]
    end

  end
end

