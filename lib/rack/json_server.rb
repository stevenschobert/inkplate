require 'rack'

class JsonServer
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    if body.empty?
      request = Rack::Request.new(env)
      verb = request.request_method
      path = Rack::Utils.unescape(request.path_info)

      if route = Api::Json.routes.match(verb, path)
        response = route.action.call(*route.values)
        [200, { "Content-Type" => "application/json" }, [response.to_json]]
      else
        [404, { "Content-Type" => "application/json" }, [ { error: "not_found"}.to_json ]]
      end
    else
      [status, headers, body]
    end
  end
end
