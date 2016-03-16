# Partial Wordpress MetaWeblog API in XMLRPC
# https://codex.wordpress.org/XML-RPC_MetaWeblog_API
module Api
  class MetaWeblog
    include XmlRpc

    self.namespace = "metaWeblog"

    def editPost(post_id, username, password, content, publish)
      if post = Post.post.where(id: post_id).first
        post.attributes = post_params(content)

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
      if post = Post.post.where(id: post_id).first
        serialize_post(post)
      else
        raise "Post not found"
      end
    end

    def getRecentPosts(blog_id, username, password, max_posts = 10)
      posts = Post.post.limit(max_posts).order(created_at: :desc)

      posts.map{ |post| serialize_post(post) }
    end

    def newPost(blog_id, username, password, content, publish)
      post = Post.new(post_params(content))

      if post.save
        post.id.to_s
      else
        raise "Error saving post"
      end
    end

    protected

    def post_params(params)
      opts = {
        kind: Post.kinds[:post],
        title: params["title"],
        status: params["post_status"],
        slug: params["wp_slug"],
        excerpt: params["mt_excerpt"],
        more_text: params["mt_text_more"],
        body: params["description"]
      }

      if custom_fields = params["custom_fields"]
        opts[:custom_fields] = custom_fields.reduce({}) do |acc, pair|
          acc[pair["key"]] = pair["value"]
          acc
        end
      end

      if opts[:status] == "private"
        opts[:status] = "invisible"
      end

      opts
    end

    def serialize_post(post)
      categories = Category.for_post(post)
      status = if post.invisible?
        "private"
      else
        post.status
      end
      custom_fields = post.custom_fields || []

      {
        postid: post.id,
        title: post.title.to_s,
        description: post.body,
        dateCreated: post.created_at.localtime.to_datetime,
        date_created_gmt: post.created_at.utc,
        date_modified: post.updated_at.localtime.to_datetime,
        date_modified_gmt: post.updated_at.utc,
        wp_post_thumbnail: "",
        permaLink: "http://google.com",
        categories: categories.map{ |c| c.name.to_s },
        mt_keywords: "",
        mt_excerpt: post.excerpt,
        mt_text_more: post.more_text,
        wp_more_text: post.more_text,
        mt_allow_comments: 0,
        mt_allow_pings: 0,
        wp_slug: post.slug,
        wp_password: "",
        wp_author_id: "",
        wp_author_display_name: "",
        post_status: status,
        wp_post_format: "",
        sticky: false,
        custom_fields: custom_fields.reduce([]) do |acc, pair|
          key, value = pair
          id = key.unpack("C*").reduce(0, &:+)
          acc.push({ id: id, key: key, value: value })
        end
      }
    end

  end
end
