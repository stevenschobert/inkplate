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

  def call(env)
    status, headers, body = app.call(env)
    req = Rack::Request.new(env)

    if req.content_type == MATCH_TYPE
      data = req.body.read
      method, params = parser().parseMethodCall(data)

      method_response = begin
        [true, dispatch(method, *params)]
      rescue XMLRPC::FaultException => e
        log_request_failure({
          logger: env["rack.logger"],
          request: req,
          body: data,
          exception: e
        })

        [false, e]
      rescue Exception => e
        log_request_failure({
          logger: env["rack.logger"],
          request: req,
          body: data,
          exception: e
        })

        [false, XMLRPC::FaultException.new(XMLRPC::BasicServer::ERR_UNCAUGHT_EXCEPTION, "Uncaught exception #{e.message} in method #{method}")]
      end

      reply = create().methodResponse(*method_response)

      [200, { "Content-Type" => "text/xml" }, [reply]]
    else
      [status, headers, body]
    end
  end

  def log_request_failure(logger: nil, request: nil, body: nil, exception: nil)
    if logger
      if exception
        logger.error("XMLRPC Error: #{ exception.message }:\n #{ body }")
      else
        logger.error("Uknown Error for XMLRPC request:\n #{ body }")
      end
    end
  end

  def setup!
    Api::XmlRpc.implementations.each do |impl|
      self.add_handler(XMLRPC.iPIMethods(impl[:namespace]), impl[:klass].new)
    end
  end

end

