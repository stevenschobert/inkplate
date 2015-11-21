class Category < ActiveRecord::Base

  has_many :categorized_posts, dependent: :destroy

  def self.for_post(post)
    post_id = if post.respond_to?(:id)
      post.id
    else
      post
    end

    self.select("c.*")
      .from("categories c, categorized_posts cp")
      .where("c.id = cp.category_id")
      .where("cp.post_id = ?", [post_id])
  end

end
