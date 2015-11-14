# Partial implementation of the Wordpress API in XMLRPC
# https://codex.wordpress.org/XML-RPC_WordPress_API
module Api
  class Wordpress

    include XmlRpc

    self.namespace = "wp"

    def getCategories(blog_id, username, password)
      categories = Category.all

      categories.map do |category|
        {
          categoryId: category.id,
          parentId: category.parent_id,
          categoryName: category.name,
          categoryDescription: category.description,
          description: category.name,
          htmlUrl: "",
          rssUrl: ""
        }
      end
    end

    def getPages(blog_id, username, password, max_pages = 10)
      []
    end

  end
end
