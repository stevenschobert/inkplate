require 'rack'
require 'xmlrpc/server'

# Cause I like my <nil>s in my XMLRPC
# https://github.com/ruby/ruby/blob/9c6779f53eb485b4653fb750a01447155b9e8fe4/lib/xmlrpc/config.rb#L25
XMLRPC::Config.module_eval { remove_const(:ENABLE_NIL_CREATE) }
XMLRPC::Config.module_eval { remove_const(:ENABLE_NIL_PARSER) }
XMLRPC::Config.const_set(:ENABLE_NIL_CREATE, true)
XMLRPC::Config.const_set(:ENABLE_NIL_PARSER, true)

class XmlRpcServer < XMLRPC::BasicServer
  MATCH_TYPE = "text/xml".freeze
  MISSING_METHOD_ERR = -32601

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
        err = e

        # emulate Wordpress' missing method error
        if e.faultCode == XMLRPC::BasicServer::ERR_METHOD_MISSING
          err = XMLRPC::FaultException.new(MISSING_METHOD_ERR, e.faultString)
        end

        log_request_failure({
          logger: env["rack.logger"],
          request: req,
          body: data,
          exception: e
        })

        [false, err]
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

