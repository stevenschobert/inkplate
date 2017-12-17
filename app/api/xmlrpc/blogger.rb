# Partial Wordpress MetaWeblog API in XMLRPC
# https://codex.wordpress.org/XML-RPC_MetaWeblog_API
module Api
  class Blogger

    include XmlRpc

    self.namespace = "blogger"

    def deletePost(app_key, post_id, username, password, publish)
      validate_user!(username, password)

      if post = Post.post.where(id: post_id).first
        if post.destroy
          true
        else
          raise "Post not destroyed"
        end
      else
        raise "Post not found"
      end
    end

    def getUserInfo(app_key, username, password)
      validate_user!(username, password)

      {
        nickname: username,
        userid: 1,
        url: "",
        firstname: "",
        lastname: ""
      }
    end

  end
end
