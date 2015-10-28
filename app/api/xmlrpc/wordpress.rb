# Partial implementation of the Wordpress API in XMLRPC
# https://codex.wordpress.org/XML-RPC_WordPress_API
module Api
  class Wordpress

    include XmlRpc

    self.namespace = "wp"

    def getPages(blog_id, username, password, max_pages = 10)
      []
    end

  end
end
