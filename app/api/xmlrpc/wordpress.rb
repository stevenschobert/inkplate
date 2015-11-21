# Partial implementation of the Wordpress API in XMLRPC
# https://codex.wordpress.org/XML-RPC_WordPress_API
module Api
  class Wordpress
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

    self.namespace = "wp"

    def getCategories(blog_id, username, password)
      categories = Category.all

      categories.map{ |category| serialize_category(category) }
    end

    def getPages(blog_id, username, password, max_pages = 10)
      time = Time.new

      [{
        page_id: 1,
        title: "Test Page 3",
        dateCreated: time.localtime.to_datetime,
        date_created_gmt: time.utc.to_datetime,
        page_status: STATUSES["private"],
        wp_slug: "test-page",
        userid: 1,
        wp_author_id: 1,
        wp_author: "stevenschobert",
        wp_author_display_name: "Steven Schobert",
        wp_password: "",
        excerpt: "this is an excerpt",
        description: "this is a desc",
        text_more: "more text",
        permaLink: "permalink",
        mt_allow_comments: 1, # ["none", "open", "closed"]
        mt_allow_pings: 0,
        wp_page_parent_id: "",
        wp_page_parent: "",
        wp_page_order: 0,
        wp_page_template: "",
        categories: [],
        custom_fields: []
      }]
    end

    def getTags(blog_id, username, password)
      [{
        tag_id: 1,
        name: "test tag",
        slug: "test-tag",
        count: 5,
        html_url: "html-url",
        rss_url: "rss-url"
      }]
    end

    def newCategory(blog_id, username, password, category)
      new_category = Category.new({
        name: category["name"],
        description: category["description"]
      })

      if new_category.save
        new_category.id
      else
        raise "Error saving category"
      end
    end

    protected

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

  end
end
