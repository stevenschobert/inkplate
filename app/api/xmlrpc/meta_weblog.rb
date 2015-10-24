# Partial Wordpress MetaWeblog API in XMLRPC
# https://codex.wordpress.org/XML-RPC_MetaWeblog_API
module Api
  class MetaWeblog

    include XMLRPC

    self.namespace = "metaWeblog"

    def getRecentPosts(blog_id, username, password, max_posts = 10)
      posts = Post.limit(max_posts).order(created_at: :desc)

      posts.map do |post|
        {
          postid: post.id,
          title: post.title,
          dateCreated: post.created_at.localtime.to_datetime,
          date_created_gmt: post.created_at.utc,
          date_modified: post.updated_at.localtime.to_datetime,
          date_modified_gmt: post.updated_at.utc
        }
      end
    end

  end
end
