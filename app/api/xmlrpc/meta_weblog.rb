# Partial Wordpress MetaWeblog API in XMLRPC
# https://codex.wordpress.org/XML-RPC_MetaWeblog_API
module Api
  class MetaWeblog
    include XmlRpc

    self.namespace = "metaWeblog"

    def editPost(post_id, username, password, content, publish)
      validate_user!(username, password)

      if post = Post.post.where(id: post_id).first
        post.attributes = post_params(content)

        if post.save
          true
        else
          raise StandardError.new("Error saving post: #{ post.errors.full_messages.join(", ") }")
        end
      else
        raise "Post not found"
      end
    end

    def getPost(post_id, username, password)
      validate_user!(username, password)

      if post = Post.post.where(id: post_id).first
        serialize_post(post)
      else
        raise "Post not found"
      end
    end

    def getRecentPosts(blog_id, username, password, max_posts = 10)
      validate_user!(username, password)

      posts = Post.post.limit(max_posts).order(created_at: :desc)

      posts.map{ |post| serialize_post(post) }
    end

    def newPost(blog_id, username, password, content, publish)
      validate_user!(username, password)

      post = Post.new(post_params(content))

      if post.save
        post.id.to_s
      else
        raise StandardError.new("Error saving post: #{ post.errors.full_messages.join(", ") }")
      end
    end

    def newMediaObject(blog_id, username, password, media)
      validate_user!(username, password)

      dropbox = DropboxInterface.new

      data = media["bits"]
      checksum = Digest::SHA1.hexdigest(data)
      path = "/#{ media["name"] }"
      mode = if media["overwrite"] == true
        :overwrite
      else
        :add
      end

      create_response = dropbox.upload(data, path: path, write_mode: mode, autorename: true)
      link_response = if create_response
        dropbox.create_link(path: create_response["path_lower"])
      end

      if create_response && link_response
        upload = Upload.where(dropbox_id: create_response["id"]).first_or_initialize

        upload.name         = media["name"]
        upload.mime_type    = media["type"]
        upload.checksum     = checksum
        upload.size         = create_response["size"]
        upload.dropbox_rev  = create_response["rev"]
        upload.dropbox_path = create_response["path_lower"]

        url_params            = { "raw" => 1 }
        dropbox_uri           = URI(link_response["url"])
        dropbox_uri_params    = URI.decode_www_form(dropbox_uri.query).to_h || {}
        dropbox_uri.query     = URI.encode_www_form(dropbox_uri_params.merge(url_params))

        upload.dropbox_url = dropbox_uri.to_s

        if upload.save
          {
            id: upload.id.to_s,
            file: upload.dropbox_path,
            type: upload.mime_type,
            url: upload.dropbox_url
          }
        else
          raise "Error saving media"
        end
      else
        raise "Error uploading media"
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

      if created_at = params["dateCreated"]
        opts[:created_at] = created_at.to_time.localtime
      end

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
