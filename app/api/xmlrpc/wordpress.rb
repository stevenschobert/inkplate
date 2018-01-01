require "linkifier"

# Partial implementation of the Wordpress API in XMLRPC
# https://codex.wordpress.org/XML-RPC_WordPress_API
module Api
  class Wordpress
    include XmlRpc

    self.namespace = "wp"

    def deletePage(blog_id, username, password, page_id)
      validate_user!(username, password)

      if page = Post.page.where(id: page_id).first
        if page.destroy
          true
        else
          raise "Page not destroyed"
        end
      else
        raise "Page not found"
      end
    end

    def deletePost(blog_id, username, password, post_id)
      validate_user!(username, password)

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

    def editPage(blog_id, page_id, username, password, content, publish)
      validate_user!(username, password)

      if page = Post.page.where(id: page_id).first
        update_params = page_params(content)

        if update_params.key?(:custom_fields)
          previous_custom_fields = page.custom_fields || {}
          update_params[:custom_fields] = previous_custom_fields.merge(update_params[:custom_fields])
        end

        page.attributes = update_params

        if page.save
          true
        else
          raise StandardError.new("Error saving page: #{ page.errors.full_messages.join(", ") }")
        end
      else
        raise "Page not found"
      end
    end

    def getAuthors(blog_id, username, password)
      validate_user!(username, password)

      [
        {
          user_id: "1",
          user_login: username,
          display_name: username
        }
      ]
    end

    def getUsers(blog_id, username, password, filter = {})
      validate_user!(username, password)

      [
        {
          user_id: "1",
          username: username,
          first_name: "",
          last_name: "",
          registered: Time.now,
          bio: "",
          email: "",
          nickname: username,
          nicename: username,
          url: "",
          display_name: username,
          roles: [ ]
        }
      ]
    end

    def getCategories(blog_id, username, password)
      validate_user!(username, password)

      categories = Category.all

      categories.map{ |category| serialize_category(category) }
    end

    def getTerm(blog_id, username, password, taxonomy, term_id)
      validate_user!(username, password)

      if taxonomy == "category"
        if category = Category.where(id: term_id).first
          serialize_category_term(category)
        else
          raise "Category ID #{ term_id } not found."
        end
      else
        raise "Invalid taxonomy."
      end
    end

    def getTerms(blog_id, username, password, taxonomy, filter = {})
      validate_user!(username, password)

      if taxonomy == "category"
        categories = Category.all
        categories.map{ |category| serialize_category_term(category) }
      else
        raise "Invalid taxonomy."
      end
    end

    def getPages(blog_id, username, password, max_pages = 10)
      validate_user!(username, password)

      pages = Post.page.limit(max_pages).order(created_at: :desc)

      pages.map{ |page| serialize_page(page) }
    end

    def getPage(blog_id, page_id, username, password)
      validate_user!(username, password)

      if page = Post.page.where(id: page_id).first
        serialize_page(page)
      else
        raise "Page not found"
      end
    end

    def getTags(blog_id, username, password)
      validate_user!(username, password)

      []
    end

    def getPost(blog_id, username, password, post_id, fields = [])
      validate_user!(username, password)

      if post = Post.where(id: post_id).first
        serialize_post(post)
      else
        raise "Post not found"
      end
    end

    def newCategory(blog_id, username, password, category)
      validate_user!(username, password)

      new_category = Category.new({
        name: category["name"],
        description: category["description"]
      })

      if new_category.save
        new_category.id
      else
        raise StandardError.new("Error saving category: #{ new_category.errors.full_messages.join(", ") }")
      end
    end

    def newPage(blog_id, username, password, content, publish)
      validate_user!(username, password)

      page = Post.new(page_params(content))

      if page.save
        page.id.to_s
      else
        raise StandardError.new("Error saving page: #{ page.errors.full_messages.join(", ") }")
      end
    end

    def newPost(blog_id, username, password, content)
      validate_user!(username, password)

      post = Post.new(post_params(content))

      if post.save
        post.id.to_s
      else
        raise StandardError.new("Error saving post: #{ post.errors.full_messages.join(", ") }")
      end
    end

    protected

    def page_params(params)
      opts = {
        kind: Post.kinds[:page],
        title: params["title"],
        status: params["page_status"],
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

    def post_params(params)
      opts = {
        kind: Post.kinds[:post],
        title: params["post_title"],
        status: params["post_status"],
        slug: params["post_name"],
        excerpt: params["post_excerpt"],
        body: params["post_content"]
      }

      if params["post_format"] == "Status"
        opts[:kind] = Post.kinds[:micro]
      end

      if created_at = params["post_date"]
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

    def serialize_category_term(category)
      {
        term_id: category.id.to_s,
        name: category.name.to_s,
        slug: "",
        taxonomy: "category",
        term_taxonomy_id: category.id.to_s,
        term_group: "",
        description: category.name.to_s,
        parent: category.parent_id.to_s,
        count: 0,
      }
    end

    def serialize_category(category)
      {
        categoryId: category.id,
        parentId: category.parent_id.to_i,
        categoryName: category.name.to_s,
        categoryDescription: category.description.to_s,
        description: category.name.to_s,
        htmlUrl: "",
        rssUrl: ""
      }
    end

    def serialize_post(post)
      categories = Category.for_post(post)
      status = if post.invisible?
        "private"
      else
        post.status
      end
      type = if post.page?
        "page"
      else
        "post"
      end
      fmt = if post.micro?
        "status"
      else
        "standard"
      end
      custom_fields = post.custom_fields || []

      {
        post_id: post.id.to_s,
        post_title: post.title.to_s,
        post_date: post.created_at.localtime.to_datetime,
        post_date_gmt: post.created_at.utc,
        post_modified: post.updated_at.localtime.to_datetime,
        post_modified_gmt: post.updated_at.utc,
        post_status: status,
        post_type: type,
        post_format: fmt,
        post_name: post.slug,
        post_author: "1",
        post_password: "",
        post_excerpt: post.excerpt,
        post_content: post.body,
        post_parent: "0",
        post_mime_type: "",
        link: Linkifier.link(post),
        guid: "",
        menu_order: 0,
        comment_status: "open",
        ping_status: "open",
        sticky: false,
        post_thumbnail: [],
        terms: categories.map{ |c| serialize_category_term(c) },
        enclosure: {},
        custom_fields: custom_fields.reduce([]) do |acc, pair|
          key, value = pair
          id = key.unpack("C*").reduce(0, &:+)
          acc.push({ id: id, key: key, value: value })
        end
      }
    end

    def serialize_page(page)
      categories = Category.for_post(page)
      status = if page.invisible?
        "private"
      else
        page.status
      end
      custom_fields = page.custom_fields || []

      {
        page_id: page.id,
        title: page.title.to_s,
        dateCreated: page.created_at.localtime.to_datetime,
        date_created_gmt: page.created_at.utc,
        page_status: status,
        wp_slug: page.slug,
        userid: 1,
        wp_author_id: 1,
        wp_author: "",
        wp_author_display_name: "",
        wp_password: "",
        excerpt: page.excerpt,
        description: page.body,
        text_more: page.more_text,
        permaLink: Linkifier.link(page),
        mt_allow_comments: 0,
        mt_allow_pings: 0,
        wp_page_parent_id: "",
        wp_page_parent: "",
        wp_page_order: 0,
        wp_page_template: "",
        categories: categories.map{ |c| c.name.to_s },
        custom_fields: custom_fields.reduce([]) do |acc, pair|
          key, value = pair
          id = key.unpack("C*").reduce(0, &:+)
          acc.push({ id: id, key: key, value: value })
        end
      }
    end

  end
end
