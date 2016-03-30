# Partial Wordpress MetaWeblog API in XMLRPC
# https://codex.wordpress.org/XML-RPC_MovableType_API
module Api
  class MoveableType

    include XmlRpc

    self.namespace = "mt"

    def getPostCategories(post_id, username, password)
      validate_user!(username, password)

      categories = Category.for_post(post_id)

      categories.map do |category|
        {
          categoryId: category.id,
          categoryName: category.name.to_s,
          isPrimary: false
        }
      end
    end

    def setPostCategories(post_id, username, password, categories)
      validate_user!(username, password)

      CategorizedPost.where(post_id: post_id).destroy_all

      categories.each do |category|
        CategorizedPost.create!(post_id: post_id, category_id: category["categoryId"])
      end

      true
    end

    def supportedTextFilters
      []
    end

  end
end
