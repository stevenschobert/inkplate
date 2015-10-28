require 'rack'
require 'xmlrpc/server'

class XmlRpcServer < XMLRPC::BasicServer
  MATCH_TYPE = "text/xml".freeze

  attr_reader :app

  def initialize(app)
    super()

    @app = app

    setup!
  end

  def setup!
    Api::XmlRpc.implementations.each do |impl|
      self.add_handler(XMLRPC.iPIMethods(impl[:namespace]), impl[:klass].new)
    end
  end

  def call(env)
    status, headers, body = app.call(env)
    req = Rack::Request.new(env)

    if req.content_type == MATCH_TYPE
      data = req.body.read

      # TODO: implement logging
      puts data

      reply = process(data)

      # TODO: implement logging
      puts reply

      [200, { "Content-Type" => "text/xml" }, [reply]]
    else
      [status, headers, body]
    end

  end
end

