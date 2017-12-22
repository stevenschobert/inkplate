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

      unless request.get_header("HTTP_X_API_KEY") == ENV["API_KEY"]
        return [401, { "Content-Type" => "application/json" }, [ { error: "unauthorized" }.to_json ]]
      end

      if route = Api::Json.routes.match(verb, path)
        if response = route.action.call(*route.values)
          return [200, { "Content-Type" => "application/json" }, [ response.to_json ]]
        end
      end

      return [404, { "Content-Type" => "application/json" }, [ { error: "not_found"}.to_json ]]
    else
      [status, headers, body]
    end
  end
end
