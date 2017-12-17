# Partial Wordpress MetaWeblog API in XMLRPC
# https://codex.wordpress.org/XML-RPC_MetaWeblog_API
module Api
  class Demo

    include XmlRpc

    self.namespace = "demo"

    def sayHello
      "Hello!"
    end

  end
end
