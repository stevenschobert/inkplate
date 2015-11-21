# Partial Wordpress MetaWeblog API in XMLRPC
# https://codex.wordpress.org/XML-RPC_MetaWeblog_API
module Api
  class Blogger

    include XmlRpc

    self.namespace = "blogger"

    def deletePost(app_key, post_id, username, password, publish)
      if post = Post.where(id: post_id).first
        if post.destroy
          true
        else
          raise "Post not destroyed"
        end
      else
        raise "Post not found"
      end
    end

  end
end
