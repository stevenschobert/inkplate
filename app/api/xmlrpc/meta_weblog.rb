# Partial Wordpress MetaWeblog API in XMLRPC
# https://codex.wordpress.org/XML-RPC_MetaWeblog_API
module Api
  class MetaWeblog
    STATUSES = {
      "published"   => "publish",     # A published post or page
      "pending"     => "pending",     # post is pending review
      "draft"       => "draft",       # a post in draft status
      "auto-draft"  => "auto-draft",  # a newly created post, with no content
      "future"      => "future",      # a post to publish in the future
      "private"     => "private",     # not visible to users who are not logged in
      "inherit"     => "iherit",      # a revision. see get_children.
      "trashed"     => "trashed"      # post is in trashbin. added with Version 2.9.
    }.freeze

    include XmlRpc

    self.namespace = "metaWeblog"

    def editPost(post_id, username, password, content, publish)
      if post = Post.where(id: post_id).first
        post.title = content["title"]

        if post.save
          true
        else
          raise "Error saving post"
        end
      else
        raise "Post not found"
      end
    end

    def getPost(post_id, username, password)
      if post = Post.where(id: post_id).first
        serialize_post(post)
      else
        raise "Post not found"
      end
    end

    def getRecentPosts(blog_id, username, password, max_posts = 10)
      posts = Post.limit(max_posts).order(created_at: :desc)

      posts.map{ |post| serialize_post(post) }
    end

    def newPost(blog_id, username, password, content, publish)
      post = Post.new({
        title: content["title"]
      })

      if post.save
        post.id.to_s
      else
        raise "Error saving post"
      end
    end

    protected

    def serialize_post(post)
      categories = Category.for_post(post)

      {
        postid: post.id,
        title: post.title.to_s,
        dateCreated: post.created_at.localtime.to_datetime,
        date_created_gmt: post.created_at.utc,
        date_modified: post.updated_at.localtime.to_datetime,
        date_modified_gmt: post.updated_at.utc,
        wp_post_thumbnail: "",
        permaLink: "http://google.com",
        categories: categories.map{ |c| c.name.to_s },
        mt_keywords: "",
        mt_excerpt: "",
        mt_text_more: "",
        wp_more_text: "",
        mt_allow_comments: 0,
        mt_allow_pings: 0,
        wp_slug: "testslug",
        wp_password: "",
        wp_author_id: "",
        wp_author_display_name: "",
        post_status: STATUSES["published"],
        wp_post_format: "",
        sticky: false,
        custom_fields: []
      }
    end

  end
end
