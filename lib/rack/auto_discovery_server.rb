require 'rack'

class AutoDiscoveryServer
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    if body.empty?
      request = Rack::Request.new(env)

      xmlrpc_url = route_for(request, "/xmlrpc.php")

      if request.path_info == "/"
        res = %Q(
          <html>
          <head>
            <link rel="EditURI" type="application/rsd+xml" title="RSD" href="#{ xmlrpc_url }?rsd" />
          </head>
          <body>
            <p>Welcome to Inkplate!</p>
          </body>
          </html>
        )
        [ 200, { "Content-Type" => "text/html" }, [ res ] ]
      elsif request.path_info == "/xmlrpc.php" && request.params.has_key?("rsd")
        res = [
          %(<?xml version="1.0" encoding="UTF-8"?>),
          %(<rsd version="1.0" xmlns="http://archipelago.phrasewise.com/rsd">),
            %(<service>),
              %(<engineName>WordPress</engineName>),
              %(<engineLink>https://wordpress.org/</engineLink>),
              %Q(<homePageLink>#{ request.base_url }</homePageLink>),
              %(<apis>),
                %Q(<api name="WordPress" blogID="1" preferred="true" apiLink="#{ xmlrpc_url }" />),
                %Q(<api name="Movable Type" blogID="1" preferred="false" apiLink="#{ xmlrpc_url }" />),
                %Q(<api name="MetaWeblog" blogID="1" preferred="false" apiLink="#{ xmlrpc_url }" />),
                %Q(<api name="Blogger" blogID="1" preferred="false" apiLink="#{ xmlrpc_url }" />),
                %Q(<api name="WP-API" blogID="1" preferred="false" apiLink="#{ route_for(request, "/wp-json/") }" />),
              %(</apis>),
            %(</service>),
          %(</rsd>)
        ]
        [ 200, { "Content-Type" => "text/xml; charset=UTF-8" }, res ]
      else
        [status, headers, body]
      end
    else
      [status, headers, body]
    end
  end

  protected

  def route_for(request, path)
    route = URI(request.base_url)
    route.path = path
    route.to_s
  end

end
