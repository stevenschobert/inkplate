# Partial Wordpress MetaWeblog API in XMLRPC
# https://codex.wordpress.org/XML-RPC_MetaWeblog_API#metaWeblog.getRecentPosts
module Api
  class MetaWeblog

    include XMLRPC

    self.namespace = "metaWeblog"

    def getRecentPosts(blog_id, username, password, max_posts = 10)
      [
        { title: "hello world" }
      ]
    end

  end
end
